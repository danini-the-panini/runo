class PlayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def create
    @game.players << Player.new(user: current_user)
    @game.broadcast

    redirect_to @game, notive: "Game was successfully joined!"
  end

  def destroy
    @game.players.find_by(user: current_user).destroy
    @game.broadcast

    redirect_to @game, notive: "Game was successfully left!"
  end

  private

    def set_game
      @game = Game.find(params[:game_id])
    end
end
