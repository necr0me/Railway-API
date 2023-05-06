class ChangeUserOnProfileInTicket < ActiveRecord::Migration[7.0]
  def change
    change_table :tickets, bulk: true do |t|
      t.remove_foreign_key :users
      t.remove :user_id, type: :integer

      t.integer :profile_id, null: false
      t.foreign_key :profiles
    end
  end
end
