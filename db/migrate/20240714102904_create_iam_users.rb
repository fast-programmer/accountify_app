class CreateIamUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :iam_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :iam_users, :email, unique: true
  end
end
