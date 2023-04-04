class ChangeDescriptionColumnOfCarriageType < ActiveRecord::Migration[7.0]
  def change
    change_column_null :carriage_types, :description, true
  end
end
