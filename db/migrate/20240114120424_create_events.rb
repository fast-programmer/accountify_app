class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.bigint :user_id, null: false
      t.bigint :tenant_id, null: false

      t.string :type, null: false, limit: 255
      t.jsonb :body
      t.datetime :created_at, null: false

      t.string :eventable_type, null: false, limit: 255
      t.bigint :eventable_id, null: false
      t.index [:eventable_type, :eventable_id]
    end
  end
end
