class AddResetEmailColumnsToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :reset_email_token
      t.datetime :reset_email_sent_at

      t.index :reset_email_token, unique: true
    end
  end
end
