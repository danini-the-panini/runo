class AddLastPlayToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :last_play, :jsonb
    add_column :games, :last_player_index, :integer
  end
end
