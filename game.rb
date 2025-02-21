require "colorize"

class Player
  attr_reader :name
  attr_accessor :cards
  
  def initialize(name)
    @name = name
  end

  def display_cards
    @cards.map.with_index do |card, index|
      "#{index}: #{card.display}"
    end.join(', ')
  end
end

class Card
  attr_accessor :color
  attr_reader :number, :plus
  
  def initialize(color, number, plus = 0)
    @color = color
    @number = number
    @plus = plus
  end

  def plus? = plus > 0
  def wildcard? = @color.nil?

  def place?(other, on_plus = false)
    return false if other.nil?
    if plus? && on_plus
      ((other.color == color || other.wildcard?) && other.plus >= plus) || (other.plus == plus)
    else
      return true if other.wildcard?
      color == other.color || number == other.number
    end
  end

  def display
    s = case number
    when :skip then "⦸"
    when :reverse then "⇄"
    when :plus then "+#{plus}"
    when :wildcard then "?"
    else number.to_s
    end

    s = "[#{s}]"

    s = s.colorize(color) if color
    s
  end
end

COLORS = %i[red yellow blue green]
CARDS = []

(1..9).each do |n|
  COLORS.each do |c|
    CARDS << Card.new(c, n)
  end
end
COLORS.each do |c|
  CARDS << Card.new(c, 0)
  2.times do
    CARDS << Card.new(c, :skip)
    CARDS << Card.new(c, :reverse)
    CARDS << Card.new(c, :plus, 2)
  end
end

4.times do
  CARDS << Card.new(nil, :plus, 4)
  CARDS << Card.new(nil, :wildcard)
end
 
class Game
  def initialize(players)
    @players = players
    @deck = CARDS.dup.shuffle
    @players.each do |player|
      player.cards = @deck.slice!(0, 7)
    end 
    @winner = nil 
    @discard = []
    @discard.unshift(@deck.shift)
    @discard.unshift(@deck.shift) while @discard.first.wildcard?
    @player_index = 0
    @plus = 0
    @dir = 1
  end

  def draw
    card = @deck.shift
    if @deck.empty?
      top_discard = @discard.slice!(0, 1)
      @deck = @discard.shuffle
      @deck.each do |card|
        if card == :wildcard || card.plus == 4
          card.color = nil
        end
      end
    end
    card
  end

  def top
    @discard.first
  end

  def finished?
    !@winner.nil?
  end

  def play
    until finished?
      puts top.display
      puts
      turn
    end

    puts
    puts "#{@winner.name} wins!!"
  end

  def turn
    player = @players[@player_index]
    puts "#{player.name}'s turn"
    puts player.display_cards
    can_play = player.cards.any? { |card| top.place?(card, @plus > 0) }
    end_turn = false
    if @plus > 0
      do_draw = !can_play
      if can_play
        puts "Draw #{@plus}? [y/n]"
        do_draw = gets.chomp.start_with?('y')
      end
      if do_draw
        puts "Drawing #{@plus} cards"
        @plus.times { player.cards << draw }
        end_turn = true
        @plus = 0
      end
    end
    unless end_turn
      if can_play
        card = nil
        i = nil
        while card.nil?
          puts
          puts "Pick card:"
          i = gets.chomp.to_i
          if i >= 0 && i < player.cards.size
            card = player.cards[i]
            card = nil unless top.place?(card)
          end
        end
        player.cards.delete_at(i)
        case player.cards.count
        when 0 then
          @winner = player
          return
        when 1 then puts "UNO!!"
        end
        if card.wildcard?
          color = nil
          while color.nil?
            puts "What color?"
            color = gets.chomp.to_sym
            color = nil unless COLORS.include?(color)
            card.color = color
          end
        end
        @plus += card.plus if card.plus?
        case card.number
        when :skip
          @player_index = (@player_index + @dir) % @players.size
        when :reverse
          @dir *= -1
        end
        @discard.unshift(card)
      else
        puts "Can't play, drawing a card"
        player.cards << draw
      end
    end
    @player_index = (@player_index + @dir) % @players.size
  end
end

puts "How many players?"
n_players = gets.chomp.to_i
puts

players = n_players.times.map do |i|
  puts "Player #{i+1} name?"
  Player.new(gets.chomp)
end
puts

game = Game.new(players)
game.play

