class LobbyChannel < ApplicationCable::Channel
  def subscribed
    stream_for Game
  end
end
