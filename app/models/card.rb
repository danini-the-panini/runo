class Card
  include StoreModel::Model

  COLORS = %i[red yellow blue green]

  attribute :id, :string
  attribute :face, :string
  attribute :plus, :integer, default: 0
  enum :color, [ *COLORS, :wild ]

  validates :face, :plus, :color, presence: true

  def initialize(...)
    super
    self.id ||= SecureRandom.uuid
  end

  def plus?
    plus > 0
  end

  def place?(other, on_plus = false, wild_color = nil)
    return false if other.nil?

    self_color = wild? ? wild_color : color

    return other.plus >= plus if plus? && on_plus
    return true if other.wild?

    self_color == other.color || same_face?(other)
  end

  def same_face?(other)
    if plus?
      plus == other.plus
    else
      face == other.face
    end
  end

end
