# -*- ruby -*-
#encoding: utf-8

require 'sequel/model'

require 'thingfish/mixins'
require 'thingfish/metastore/pggraph' unless defined?( Thingfish::Metastore::PgGraph )


### A row representing a relationship between two node objects.
###
class Thingfish::Metastore::PgGraph::Edge < Sequel::Model( :edges )

	# Related resource associations
	many_to_one :node, :key => :id_p

	# Dataset methods
	#
	dataset_module do
		#########
		protected
		#########

		### Returns a Sequel expression suitable for use as the key of a query against
		### the specified property field.
		###
		def prop_expr( field )
			return Sequel.pg_jsonb( :prop ).get_text( field.to_s )
		end
	end


	### Do some initial attribute setup for new objects.
	###
	def initialize( * )
		super
		self[ :prop ] ||= Sequel.pg_jsonb({})
	end


	#########
	protected
	#########

	### Proxy method -- fetch a value from the edge property hash if it exists.
	###
	def method_missing( sym, *args, &block )
		return self.prop[ sym.to_s ] || super
	end

end # Thingfish::Metastore::PgGraph::Edge

