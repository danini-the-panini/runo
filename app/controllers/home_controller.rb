class HomeController < ApplicationController
  def index
    @your_games = current_user&.games&.playing
    @games = Game.lobby
  end
end
