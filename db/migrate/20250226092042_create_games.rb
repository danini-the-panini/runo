class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.integer :status, default: 0, null: false
      t.belongs_to :user
      t.belongs_to :winner, null: true

      t.timestamps
    end
  end
end
