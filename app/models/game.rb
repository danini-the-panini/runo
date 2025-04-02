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

  def user_stream(user)
    "game_#{id}_#{user.id}"
  end

  def player_stream(player)
    user_stream(player.user)
  end

  def broadcast(*other_users)
    if abandoned?
      LobbyChannel.broadcast_to(Game, { type: "destroy", id: })
    else
      LobbyChannel.broadcast_to(Game, { type: "update", game: lobby_data })
    end
    players.each do
      ActionCable.server.broadcast(player_stream(it), player_data(it))
    end
    other_users.each do
      ActionCable.server.broadcast(user_stream(it), user_data(it))
    end
  end

  def broadcast_to_lobby
    LobbyChannel.broadcast_to(Game, { type: "create", game: lobby_data })
  end

  def lobby_data
    { id:, player_count: players.count }
  end

  def user_data(player_user)
    player_data(players.find_by(user: player_user))
  end

  def player_data(player)
    data = {
      id:, status:,
      user: user.email,
      joined: players.include?(player),
      yours: player&.user == user
    }

    case status
    when 'lobby'
      data.merge!(
        players: players
          .order(created_at: :asc)
          .map { { id: it.id, name: it.user.email } }
      )
    when 'playing'
      your_turn = player == current_player
      can_draw = your_turn && (plus > 0 || player.cards.all?{ !place?(it) })
      data.merge!(
        deck_size: deck.count,
        discard_size: discard.count,
        top: top.as_json,
        cards: player.cards.map { it.as_json.merge(place: your_turn && place?(it)) },
        plus:, color:, dir:, can_draw:, your_turn:,
        runo: player.runo?,
        players: players.order(created_at: :asc)
          .reject { it == player }
          .map { {
            id: it.id,
            name: it.user.email,
            card_count: it.cards.count,
            current: it == current_player,
            runo: it.runo?
          } }
      )
    when 'finished'
      data[:winner] = winner == player ? 'you' : winner.user.email
    end

    data.deep_transform_keys { it.to_s.camelize(:lower) }
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
