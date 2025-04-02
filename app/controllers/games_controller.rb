class GamesController < ApplicationController
  before_action :set_game, only: %i[show update destroy]
  before_action :authenticate_user!

  def index
    render json: {
      your_games: current_user.games.playing.map(&:lobby_data),
      games: Game.lobby.map(&:lobby_data)
    }
  end

  # GET /games/1 or /games/1.json
  def show
    @user_data = @game.user_data(current_user)

    respond_to do |format|
      format.html { render inertia: "Game", props: { game: @user_data } }
      format.json { render json: @user_data }
    end
  end

  # POST /games or /games.json
  def create
    @game = Game.create(user: current_user)
    @game.players << Player.new(user: current_user)

    render json: @game.user_data(current_user)
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.abandoned!

    head :no_content
  end

  def update
    @game.start! if @game.lobby? && @game.players.length >= 2

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params.expect(:id))
    end
end
