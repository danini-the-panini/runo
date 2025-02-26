class HomeController < ApplicationController
  def index
    @games = Game.lobby
  end
end
