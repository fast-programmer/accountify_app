class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.bigint :account_id, null: false
      t.bigint :user_id, null: false

      t.text :body_class_name, null: false
      t.jsonb :body_json, null: false

      t.timestamps
    end
  end
end
