require "application_system_test_case"

class GamesTest < ApplicationSystemTestCase
  setup do
    @game = games(:one)
    @user = users(:one)
    sign_in @user
  end

  test "visiting the index" do
    visit root_url
    assert_selector ".logo"
  end

  test "should create game" do
    visit root_url
    click_on "New game"

    assert_text "Game was successfully created"
    click_on "Back to lobby"
  end

  test "should abandon Game" do
    visit game_url(@game)
    click_on "Abandon", match: :first

    assert_text "Game was successfully destroyed"
  end
end
