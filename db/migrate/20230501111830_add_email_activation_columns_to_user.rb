class AddEmailActivationColumnsToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :unconfirmed_email
      t.string :confirmation_token
      t.boolean :activated, null: false, default: false

      t.index :unconfirmed_email, unique: true
      t.index :confirmation_token, unique: true
    end
  end
end
