# -*- ruby -*-
#encoding: utf-8

require 'sequel/model'

require 'thingfish/mixins'
require 'thingfish/metastore/pggraph' unless defined?( Thingfish::Metastore::PgGraph )


# A row of metadata describing an asset in a Thingfish store.
class Thingfish::Metastore::PgGraph::Node < Sequel::Model( :nodes )
	include Thingfish::Normalization

	# Related resources for this node
	one_to_many :related_nodes, :key => :id_p, :class => 'Thingfish::Metastore::PgGraph::Edge'

	# Edge relation if this node is a related resource
	one_to_one :related_to, :key => :id_c, :class => 'Thingfish::Metastore::PgGraph::Edge'

	# Allow instances to be created with a primary key
	unrestrict_primary_key


	# Dataset methods
	dataset_module do

		### Dataset method: Limit results to metadata which is for a related resource.
		###
		def related
			return self.join_edges( :rel ).exclude( :rel__id_c => nil )
		end


		### Dataset method: Limit results to metadata which is not for a related resource.
		###
		def unrelated
			return self.join_edges( :notrel ).filter( :notrel__id_c => nil )
		end


		### Dataset method: Limit results to records whose operational or user
		### metadata matches the values from the specified +hash+.
		###
		def where_metadata( hash )
			ds = self
			hash.each do |field, value|

				# Direct DB column
				#
				if self.model.metadata_columns.include?( field.to_sym )
					ds = ds.where( field.to_sym => value )

				# User metadata or edge relationship
				#
				else
					if field.to_sym == :relationship
						ds = self.join_edges.filter( Sequel.pg_jsonb( :edges__prop ).get_text( field.to_s ) => value )

					elsif field.to_sym == :relation
						ds = self.join_edges.filter( :edges__id_p => value )

					else
						ds = ds.where( self.user_metadata_expr(field) => value )
					end
				end
			end

			return ds
		end


		### Dataset method: Order results by the specified +columns+.
		###
		def order_metadata( *columns )
			columns.flatten!
			ds = self
			columns.each do |column|
				if Thingfish::Metastore::PgGraph::Node.metadata_columns.include?( column.to_sym )
					ds = ds.order_append( column.to_sym )
				else
					ds = ds.order_append( self.user_metadata_expr(column) )
				end
			end

			return ds
		end



		#########
		protected
		#########

		### Return a dataset linking related nodes to edges.
		###
		def join_edges( aka=nil )
			return self.join_table( :left, :edges, { :id_c => :nodes__id }, { :table_alias => aka } )
		end


		### Returns a Sequel expression suitable for use as the key of a query against
		### the specified user metadata field.
		def user_metadata_expr( field )
			return Sequel.pg_jsonb( :user_metadata ).get_text( field.to_s )
		end

	end # dataset_module


	### Return a new Metadata object from the given +oid+ and one-dimensional +hash+
	### used by Thingfish.
	def self::from_hash( hash )
		metadata = Thingfish::Normalization.normalize_keys( hash )

		md = new

		md.format        = metadata.delete( 'format' )
		md.extent        = metadata.delete( 'extent' )
		md.created       = metadata.delete( 'created' )
		md.uploadaddress = metadata.delete( 'uploadaddress' ).to_s

		md.user_metadata = Sequel.pg_jsonb( metadata )

		return md
	end


	### Return the columns of the table that are used for resource metadata.
	def self::metadata_columns
		return self.columns - [self.primary_key, :user_metadata]
	end


	### Do some initial attribute setup for new objects.
	def initialize( * )
		super
		self[ :user_metadata ] ||= Sequel.pg_jsonb({})
	end


	### Return the metadata as a Hash; overridden from Sequel::Model to
	### merge the user and system pairs together.
	def to_hash
		hash = self.values.dup

		hash.delete( :id )
		hash.merge!( hash.delete(:user_metadata) )

		if related_to = self.related_to
			hash.merge!( related_to.prop )
			hash[ :relation ] = related_to.id_p
		end

		return normalize_keys( hash )
	end


	### Merge new metadata +values+ into the metadata for the resource
	def merge!( values )

		# Extract and set the column-metadata values first
		self.class.metadata_columns.each do |col|
			next unless values.key?( col.to_s )
			self[ col ] = values.delete( col.to_s )
		end

		self.user_metadata.merge!( values )
	end


	### Hook creation for new related resources, divert relation data to
	### a new edge row.
	###
	def around_save
		relationship = self.user_metadata.delete( 'relationship' )
		relation     = self.user_metadata.delete( 'relation' )

		super

		if relation
			edge = Thingfish::Metastore::PgGraph::Edge.new
			edge.prop[ 'relationship' ] = relationship
			edge.id_p = relation
			edge.id_c = self.id
			edge.save
		end
	end


	#########
	protected
	#########

	### Proxy method -- fetch a value from the metadata hash if it exists.
	def method_missing( sym, *args, &block )
		return self.user_metadata[ sym.to_s ] || super
	end

end # Thingfish::Metastore::PgGraph::Node

