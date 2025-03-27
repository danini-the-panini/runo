require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @game = games(:one)
    sign_in @user
  end

  test "should create game" do
    assert_difference("Game.count") do
      post games_url
    end

    assert_redirected_to game_url(Game.last)
  end

  test "should show game" do
    get game_url(@game)
    assert_response :success
  end

  test "should update game" do
    patch game_url(@game), params: { game: { status: @game.status } }
    assert_redirected_to game_url(@game)
  end

  test "should destroy game" do
    delete game_url(@game)

    assert @game.reload.abandoned?
    assert_redirected_to root_url
  end
end
