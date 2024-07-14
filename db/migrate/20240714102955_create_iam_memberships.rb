class CreateIamMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :iam_memberships do |t|
      t.references :user, null: false, foreign_key: { to_table: :iam_users }
      t.references :tenant, null: false, foreign_key: { to_table: :iam_tenants }

      t.timestamps
    end
  end
end
