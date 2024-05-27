class CreateAccountifyOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_organisations do |t|
      t.bigint :iam_tenant_id, null: false

      t.text :name, null: false

      t.datetime :deleted_at

      t.timestamps
    end

    add_index :accountify_organisations, [:iam_tenant_id, :deleted_at]
  end
end
