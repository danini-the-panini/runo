class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user

  attribute :cards, Card.to_array_type
end
