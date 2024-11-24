class CreateAccountifyContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :accountify_contacts do |t|
      t.bigint :tenant_id, null: false, index: true

      t.references :organisation, null: false,
        foreign_key: { to_table: :accountify_organisations }, index: true

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false

      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
