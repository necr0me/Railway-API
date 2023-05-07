class RenamePassingTrainToTrainStop < ActiveRecord::Migration[7.0]
  def change
    rename_table :passing_trains, :train_stops
  end
end
