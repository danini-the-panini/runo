class AddAttributesToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :player_index, :integer, null: false, default: 1
    add_column :games, :plus, :integer, null: false, default: 0
    add_column :games, :dir, :integer, null: false, default: 1
  end
end
