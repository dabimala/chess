defmodule ChessWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, _params, socket) do
    socket = assign(socket, :game_id, game_id)
    {:ok, socket}
  end

  def handle_in("make_move", %{"from" => from, "to" => to, "player" => player}, socket) do
    broadcast!(socket, "move_made", %{
      from: from,
      to: to,
      player: player
    })
    {:noreply, socket}
  end

  def handle_in("join_game", %{"player_id" => player_id}, socket) do
    broadcast!(socket, "player_joined", %{player_id: player_id})
    {:noreply, socket}
  end
end
