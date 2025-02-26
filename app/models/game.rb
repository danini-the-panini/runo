class Game < ApplicationRecord

  DEFAULT_DECK = [
    *(1..9).flat_map do |n|
      Card::COLORS.flat_map do |c|
        Card.new(color: c, face: n)
      end
    end,
    *Card::COLORS.flat_map do |c|
      [
        Card.new(color: c, face: '0'),
        *2.times.flat_map do
          [
            Card.new(color: c, face: 'skip'),
            Card.new(color: c, face: 'revrse'),
            Card.new(color: c, face: 'plus', plus: 2)
          ]
        end
      ]
    end,
    *4.times.flat_map do
      [
        Card.new(color: 'wild', face: 'plus', plus: 4),
        Card.new(color: 'wild', face: 'wild')
      ]
    end
  ].freeze

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
  validate :enough_players, if: :playing?

  attribute :deck, Card.to_array_type
  attribute :discard, Card.to_array_type

  before_create :shuffle_deck

  def start!
    deal
    playing!
  end

  private

    def enough_players
      errors.add(:players, :blank) if players.count < 2
    end

    def shuffle_deck
      self.deck = DEFAULT_DECK.dup.shuffle
    end

    def deal
      7.times do
        players.each do |player|
          player.cards << draw
        end
      end
      players.each(&:save!)
      discard.unshift(deck.shift)
      discard.unshift(deck.shift) while discard.first.wild?
    end

    def draw
      card = deck.shift
      if deck.empty?
        top_discard = discard.slice!(0, 1)
        self.deck = discard.shuffle
        deck.each do |card|
          card.color = 'wild' if card.wild?
        end
      end
      card
    end

    def top
      discard.first
    end

end
