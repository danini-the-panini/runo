class TurnsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_game
  
  def create
    end_turn = false
    if @game.current_player.user == current_user
      case params[:play]
      when 'card'
        if @game.place?(card) && (!card.wild? || params[:color].present?)
          @game.discard.unshift(card)
          @game.color = card.wild? ? params[:color] : nil
          player.cards.delete(card)
          player.save!
          if player.cards.empty?
            @game.winner = current_user
            @game.finished!
          else
            case card.face
            when 'skip'
              @game.next_player
            when 'reverse'
              @game.reverse
            when 'plus'
              @game.plus += card.plus
            end
            end_turn = true
          end
        end
      when 'draw'
        if @game.plus > 0
          @game.plus.times { player.cards << @game.draw }
          @game.plus = 0
          player.save!
          end_turn = true
        else
          if player.cards.all? { !@game.place?(it) }
            draw = @game.draw
            if @game.place?(draw)
              @game.discard.unshift(draw)
            else
              player.cards << draw
              player.save!
            end
            end_turn = true
          end
        end
      end
    end

    if end_turn
      @game.next_player
      @game.save!
    end

    redirect_to @game
  end

  private

    def set_game
      @game = Game.find(params[:game_id])
    end

    def player
      @_player ||= @game.players.find_by(user: current_user)
    end

    def card
      @_card ||= player.cards.find { it.id == params[:card_id] }
    end

end
