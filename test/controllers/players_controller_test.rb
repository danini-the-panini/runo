require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @game = games(:two)
    sign_in @user
  end

  test "should create player" do
    assert_difference("Player.count") do
      post game_players_url(@game)
    end

    assert_redirected_to game_url(@game)
  end

  test "should destroy player" do
    @game.players << Player.new(user: @user)
    assert_difference("Player.count", -1) do
      delete game_players_url(@game)
    end

    assert_redirected_to game_url(@game)
  end
end
