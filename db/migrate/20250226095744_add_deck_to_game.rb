class AddDeckToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :deck, :json, null: false, default: []
    add_column :games, :discard, :json, null: false, default: []
  end
end
