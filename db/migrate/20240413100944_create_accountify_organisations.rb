class CreateAccountifyOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_organisations do |t|
      t.bigint :tenant_id, null: false

      t.integer :lock_version, default: 0, null: false

      t.text :name, null: false

      t.datetime :deleted_at

      t.timestamps
    end

    add_index :accountify_organisations, [:tenant_id, :deleted_at]
  end
end
