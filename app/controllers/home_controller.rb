class HomeController < ApplicationController
  def index
    @your_games = current_user&.games&.playing
    @games = Game.lobby

    if user_signed_in?
      render inertia: "Lobby"
    else
      render inertia: "Home"
    end
  end
end
