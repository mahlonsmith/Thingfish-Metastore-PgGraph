# vim: set nosta noet ts=4 sw=4:

### The initial Thingfish::Metastore::PgGraph DDL.
###
Sequel.migration do
	up do
		create_table( :nodes ) do
			uuid        :id,           primary_key: true
			text        :format,        null: false
			int         :extent,        null: false
			timestamptz :created,       null: false, default: Sequel.function(:now)
			inet        :uploadaddress, null: false
			jsonb       :user_metadata, null: false, default: '{}'
		end

		create_table( :edges ) do
			uuid  :id_p, null: false
			uuid  :id_c, null: false
			jsonb :prop,  null: false, default: '{}'

			index :id_p
			index :id_c

			# Remove relationships when a node is deleted.
			foreign_key [:id_p], :nodes, name: 'edges_p_fkey', key: :id, on_delete: :cascade, on_update: :cascade
			foreign_key [:id_c], :nodes, name: 'edges_c_fkey', key: :id, on_delete: :cascade, on_update: :cascade
		end

		# Add functional index from JSON edge props
		run "CREATE INDEX relation_idx ON edges ( (prop->>'relationship') )"

		# Disallow a node linking to itself -- no self loops.
		run 'ALTER TABLE edges ADD CONSTRAINT no_self_edge_chk CHECK ( id_p <> id_c )'

		# Allow only a single link between any two nodes, enforcing relations
		# to be directional parent->child.
		run 'CREATE UNIQUE INDEX pair_unique_idx ON edges USING btree ((LEAST(id_p, id_c)), (GREATEST(id_p, id_c)))'
	end

	down do
		drop_table( :nodes, cascade: true )
		drop_table( :edges, cascade: true )
	end
end

