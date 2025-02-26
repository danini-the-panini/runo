class GamesController < ApplicationController
  before_action :set_game, only: %i[ show destroy ]
  before_action :authenticate_user!

  # GET /games/1 or /games/1.json
  def show
  end

  # POST /games or /games.json
  def create
    @game = Game.create(user: current_user)
    @game.players << Player.new(user: current_user)

    respond_to do |format|
      format.html { redirect_to @game, notice: "Game was successfully created." }
      format.json { render :show, status: :created, location: @game }
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy!

    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params.expect(:id))
    end
end
