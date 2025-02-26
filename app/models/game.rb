class Game < ApplicationRecord

  enum :status, {
    lobby: 0,
    playing: 1,
    finished: 2,
    abandoned: 3
  }

  has_many :players, dependent: :destroy
  has_many :users, through: :players
  belongs_to :winner, class_name: 'User', optional: true
  belongs_to :user

  validates :winner, presence: true, if: :finished?
  validate :enough_players, unless: :lobby?

  private

    def enough_players
      errors.add(:players, :blank) if players.count < 2
    end

end
