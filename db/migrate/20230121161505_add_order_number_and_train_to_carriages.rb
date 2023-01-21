class AddOrderNumberAndTrainToCarriages < ActiveRecord::Migration[7.0]
  def change
    add_column :carriages, :order_number, :integer

    add_reference :carriages, :train, foreign_key: true
  end
end
