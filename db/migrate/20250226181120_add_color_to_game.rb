class AddColorToGame < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :color, :integer
  end
end
