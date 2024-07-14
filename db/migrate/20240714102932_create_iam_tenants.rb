class CreateIamTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :iam_tenants do |t|
      t.string :subdomain, null: false

      t.timestamps
    end
    add_index :iam_tenants, :subdomain, unique: true
  end
end
