class CreateAccountifyOrganisation < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_organisations do |t|
      t.bigint :tenant_id, null: false
      t.text :name, null: false

      t.timestamps
    end
  end
end
