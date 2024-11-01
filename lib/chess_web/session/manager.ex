defmodule ChessWeb.Session.Manager do
  alias ChessWeb.Session.Server

  def create_game do
    game_id = generate_game_id()
    DynamicSupervisor.start_child(Chess.GameSupervisor, {Server, game_id})
    {:ok, game_id}
  end

  def join_game(game_id, player_id) do
    Server.join_game(game_id, player_id)
  end

  def get_game(game_id) do
    Server.get_state(game_id)
  end

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64()
  end
end
