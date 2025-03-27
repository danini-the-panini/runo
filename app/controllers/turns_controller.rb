class TurnsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_game
  
  def create
    end_turn = false
    if params[:play] == 'runo'
      player.update!(runo: true)
      @game.last_player_index = @game.player_index_of(player)
      @game.last_play = { play: 'runo' }
    elsif params[:play] == 'not_runo'
      other_player = @game.players.find(params[:player_id])
      unless other_player.runo?
        @game.last_player_index = @game.player_index_of(player)
        @game.last_play = { play: 'not_runo' }
        2.times { other_player.cards << @game.draw }
      end
      other_player.update!(runo: true)
    elsif @game.current_player.user == current_user
      player.update!(runo: false)
      @game.last_player_index = @game.player_index
      @game.last_play = params.permit(:play, :color, :card_id).to_h
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
          @game.last_play[:draw] = @game.plus
          @game.plus.times { player.cards << @game.draw }
          @game.plus = 0
          player.save!
          end_turn = true
        elsif player.cards.all? { !@game.place?(it) }
          @game.last_play[:draw] = 1
          draw = @game.draw
          player.cards << draw
          player.save!
          end_turn = true unless @game.place?(draw)
        end
      end
    end

    if end_turn
      @game.next_player
    end

    @game.save!
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
