# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'configurability'
require 'sequel'
require 'strelka'
require 'strelka/mixins'

require 'thingfish'
require 'thingfish/mixins'
require 'thingfish/metastore'

# Toplevel namespace
class Thingfish::Metastore::PgGraph < Thingfish::Metastore
	extend Loggability,
	       Configurability,
	       Strelka::MethodUtilities
	include Thingfish::Normalization


	# Load Sequel extensions/plugins
	Sequel.extension :migration


	# Package version
	VERSION = '0.3.1'

	# Version control revision
	REVISION = %q$Revision: 686fbfe638bd $

	# The data directory that contains migration files.
	#
	DATADIR = if ENV['THINGFISH_METASTORE_PGGRAPH_DATADIR']
				   Pathname( ENV['THINGFISH_METASTORE_PGGRAPH_DATADIR'] )
			   elsif Gem.loaded_specs[ 'thingfish-metastore-pggraph' ] && File.exist?( Gem.loaded_specs['thingfish-metastore-pggraph'].datadir )
				   Pathname( Gem.loaded_specs['thingfish-metastore-pggraph'].datadir )
			   else
				   Pathname( __FILE__ ).dirname.parent.parent.parent + 'data/thingfish-metastore-pggraph'
			   end

	log_as :thingfish_metastore_pggraph

	# Configurability API -- load the `pg_metastore`
	configurability 'thingfish.pggraph_metastore' do

		# The Sequel::Database that's used to access the metastore tables
		setting :uri, default: 'postgres:/thingfish'

		# The number of seconds to consider a "slow" query
		setting :slow_query_seconds, default: 0.01
	end

	# The Sequel::Database that's used to access the metastore tables
	singleton_attr_accessor :db


	### Set up the metastore database and migrate to the latest version.
	def self::setup_database
		Sequel.extension :pg_json_ops
		Sequel.split_symbols = true
		Sequel::Model.require_valid_table = false

		self.db = Sequel.connect( self.uri )
		self.db.logger = Loggability[ Thingfish::Metastore::PgGraph ]
		self.db.extension :pg_streaming
		self.db.stream_all_queries = true
		self.db.sql_log_level = :debug
		self.db.extension( :pg_json )
		self.db.log_warn_duration = self.slow_query_seconds

		# Ensure the database is current.
		#
		unless Sequel::Migrator.is_current?( self.db, self.migrations_dir.to_s )
			self.log.info "Installing database schema..."
			Sequel::Migrator.apply( self.db, self.migrations_dir.to_s )
		end
	end


	### Tear down the configured metastore database.
	def self::teardown_database
		self.log.info "Tearing down database schema..."
		Sequel::Migrator.apply( self.db, self.migrations_dir.to_s, 0 )
	end


	### Return the current database migrations directory as a Pathname
	def self::migrations_dir
		return DATADIR + 'migrations'
	end


	### Configurability API -- set up the metastore with the `pg_metastore` section of
	### the config file.
	def self::configure( config=nil )
		super
		self.setup_database if self.uri
	end


	### Set up the metastore.
	def initialize( * ) # :notnew:
		require 'thingfish/metastore/pggraph/node'
		require 'thingfish/metastore/pggraph/edge'

		Thingfish::Metastore::PgGraph::Node.dataset = self.class.db[ :nodes ]
		Thingfish::Metastore::PgGraph::Edge.dataset = self.class.db[ :edges ]
		@model = Thingfish::Metastore::PgGraph::Node
	end


	######
	public
	######

	##
	# The Sequel model representing the metadata rows.
	attr_reader :model


	#
	# :section: Thingfish::Metastore API
	#

	### Return an Array of all stored oids.
	def oids
		return self.each_oid.to_a
	end


	### Iterate over each of the store's oids, yielding to the block if one is given
	### or returning an Enumerator if one is not.
	def each_oid( &block )
		return self.model.select_map( :id ).each( &block )
	end


	### Save the +metadata+ Hash for the specified +oid+.
	def save( oid, metadata )
		md = self.model.from_hash( metadata )
		md.id = oid
		md.save
	end


	### Fetch the data corresponding to the given +oid+ as a Hash-ish object.
	def fetch( oid, *keys )
		metadata = self.model[ oid ] or return nil

		if keys.empty?
			return metadata.to_hash
		else
			keys = normalize_keys( keys )
			values = metadata.to_hash.values_at( *keys )
			return Hash[ [keys, values].transpose ]
		end
	end


	### Fetch the value of the metadata associated with the given +key+ for the
	### specified +oid+.
	def fetch_value( oid, key )
		metadata = self.model[ oid ] or return nil
		key = key.to_sym
		return metadata[ key ] || metadata.user_metadata[ key ]
	end


	### Fetch UUIDs related to the given +oid+.
	def fetch_related_oids( oid )
		oid = normalize_oid( oid )
		oid = self.model[ oid ]
		return [] unless oid
		return oid.related_nodes.map( &:id_c )
	end


	### Search the metastore for UUIDs which match the specified +criteria+ and
	### return them as an iterator.
	def search( options={} )
		ds = self.model.naked.select( :id )
		self.log.debug "Starting search with %p" % [ ds ]

		ds = self.omit_related_resources( ds, options )
		ds = self.apply_search_criteria( ds, options )
		ds = self.apply_search_order( ds, options )
		ds = self.apply_search_direction( ds, options )
		ds = self.apply_search_limit( ds, options )

		self.log.debug "Dataset for search is: %s" % [ ds.sql ]

		return ds.map {|row| row[:id] }
	end


	### Update the metadata for the given +oid+ with the specified +values+ hash.
	def merge( oid, values )
		values = normalize_keys( values )

		md = self.model[ oid ] or return nil
		md.merge!( values )
		md.save
	end


	### Remove all metadata associated with +oid+ from the Metastore.
	def remove( oid, *keys )
		self.model[ id: oid ].destroy
	end


	### Remove all metadata associated with +oid+ except for the specified +keys+.
	def remove_except( oid, *keys )
		keys = normalize_keys( keys )

		md = self.model[ oid ] or return nil
		md.user_metadata.keep_if {|key,_| keys.include?(key) }
		md.save
	end


	### Returns +true+ if the metastore has metadata associated with the specified +oid+.
	def include?( oid )
		return self.model.count( id: oid ).nonzero?
	end


	### Returns the number of objects the store contains.
	def size
		return self.model.count
	end


	#########
	protected
	#########

	### Omit related resources from the search dataset +ds+ unless the given
	### +options+ specify otherwise.
	def omit_related_resources( ds, options )
		unless options[:include_related]
			self.log.debug "  omitting entries for related resources"
			ds = ds.unrelated
		end
		return ds
	end


	### Apply the search :criteria from the specified +options+ to the collection
	### in +ds+ and return the modified dataset.
	def apply_search_criteria( ds, options )
		if (( criteria = options[:criteria] ))
			criteria.each do |field, value|
				self.log.debug "  applying criteria: %p => %p" % [ field.to_s, value ]
				ds = ds.where_metadata( field => value )
			end
		end

		return ds
	end


	### Apply the search :order from the specified +options+ to the collection in
	### +ds+ and return the modified dataset.
	def apply_search_order( ds, options )
		if options[:order]
			columns = Array( options[:order] )
			self.log.debug "  ordering results by columns: %p" % [ columns ]
			ds = ds.order_metadata( columns )
		end

		return ds
	end


	### Apply the search :direction from the specified +options+ to the collection
	### in +ds+ and return the modified dataset.
	def apply_search_direction( ds, options )
		ds = ds.reverse if options[:direction] && options[:direction] == 'desc'
		return ds
	end


	### Apply the search :limit from the specified +options+ to the collection in
	### +ds+ and return the modified dataset.
	def apply_search_limit( ds, options )
		if (( limit = options[:limit] ))
			self.log.debug "  limiting to %s results" % [ limit ]
			offset = options[:offset] || 0
			ds = ds.limit( limit, offset )
		end

		return ds
	end

end # class Thingfish::Metastore::PgGraph

