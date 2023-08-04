class CreateOutboxerMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :outboxer_messages do |t|
      t.references :message, polymorphic: true, null: false
      t.text :status, null: false

      t.timestamps
    end

    add_index :outboxer_messages, %i[status created_at]
    add_index :outboxer_messages, %i[message_type message_id], unique: true
  end
end
