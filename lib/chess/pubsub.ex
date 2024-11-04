defmodule Chess.PubSub do
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Chess.PubSub, topic)
  end

  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(Chess.PubSub, topic, message)
  end
end
