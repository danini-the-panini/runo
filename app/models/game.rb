class Game < ApplicationRecord
  DEFAULT_DECK = [
    *(1..9).flat_map do |n|
      Card::COLORS.flat_map do |c|
        Card.new(color: c, face: n)
      end
    end,
    *Card::COLORS.flat_map do |c|
      [
       Card.new(color: c, face: "0"),
        *2.times.flat_map do
          [
            Card.new(color: c, face: "skip"),
            Card.new(color: c, face: "reverse"),
            Card.new(color: c, face: "plus", plus: 2)
          ]
        end
      ]
    end,
    *4.times.flat_map do
      [
        Card.new(color: "wild", face: "plus", plus: 4),
        Card.new(color: "wild", face: "wild")
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
  belongs_to :winner, class_name: "User", optional: true
  belongs_to :user

  validates :winner, presence: true, if: :finished?
  validate :enough_players, if: :playing?

  attribute :deck, Card.to_array_type
  attribute :discard, Card.to_array_type

  enum :color, Card.colors.keys

  before_create :shuffle_deck

  after_create :broadcast_to_lobby
  after_update :broadcast

  def start!
    deal
    playing!
  end

  def top
    discard.first
  end

  def place?(card)
    top.place?(card, plus > 0, color)
  end

  def draw
    card = deck.shift
    if deck.empty?
      top_discard = discard.slice!(0, 1)
      self.deck = discard.shuffle
      deck.each do |card|
        card.color = "wild" if card.wild?
      end
    end
    card
  end

  def current_player
    players.order(created_at: :asc)[player_index]
  end

  def last_player
    return nil if last_player_index.nil?

    players.order(created_at: :asc)[last_player_index]
  end

  def player_index_of(player)
    players.order(created_at: :asc).index(player)
  end

  def next_player
    self.player_index = (self.player_index + self.dir) % players.length
  end

  def reverse
    self.dir *= -1
  end

  def broadcast
    if abandoned?
      broadcast_remove_to "games", target: "game_#{id}"
    else
      broadcast_replace_to "games", target: "game_#{id}", partial: "games/lobby_game", locals: { game: self }
    end
    users.each do |user|
      broadcast_replace_to "game_#{id}_#{user.id}", locals: { game: self, current_user: user, last_play: last_player && last_player.user != user }
    end
  end

  def broadcast_to_lobby
    broadcast_append_to "games", partial: "games/lobby_game", locals: { game: self }
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
end
