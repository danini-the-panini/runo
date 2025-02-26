class AddCardsToPlayer < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :cards, :json, null: false, default: []
  end
end
