class AddRunoToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :runo, :boolean, null: false, default: false
  end
end
