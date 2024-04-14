class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.bigint :iam_user_id, null: false
      t.bigint :iam_tenant_id, null: false

      t.text :type, null: false

      t.text :eventable_type, null: false
      t.bigint :eventable_id, null: false

      t.jsonb :body

      t.datetime :created_at, null: false
    end

    add_index :events, [:eventable_type, :eventable_id]
  end
end
