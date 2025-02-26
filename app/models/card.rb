class Card
  include StoreModel::Model

  COLORS = %i[red yellow blue green]

  attribute :face, :string
  attribute :plus, :integer, default: 0
  enum :color, [*COLORS, :wild]

  validates :face, :plus, :color, presence: true

  def plus?
    plus > 0
  end

  def place?(other, on_plus = false)
    return false if other.nil?

    if plus? && on_plus
      ((other.color == color || other.wild?) && other.plus >= plus) || (other.plus == plus)
    else
      return true if other.wild?

      color == other.color || face == other.face
    end
  end
end
