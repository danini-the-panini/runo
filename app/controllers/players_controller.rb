class PlayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def create
    @game.players << Player.new(user: current_user)
    @game.broadcast

    head :no_content
  end

  def destroy
    @game.players.find_by(user: current_user).destroy
    @game.broadcast(current_user)

    head :no_content
  end

  private

    def set_game
      @game = Game.find(params[:game_id])
    end
end
