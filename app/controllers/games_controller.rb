class GamesController < ApplicationController
  before_action :set_game, only: %i[show update destroy]
  before_action :authenticate_user!

  # GET /games/1 or /games/1.json
  def show
  end

  # POST /games or /games.json
  def create
    @game = Game.create(user: current_user)
    @game.players << Player.new(user: current_user)

    redirect_to @game, notice: "Game was successfully created."
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.abandoned!

    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    @game.start! if @game.lobby? && @game.players.length >= 2

    redirect_to @game, notice: "Game was successfully started!"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params.expect(:id))
    end

end
