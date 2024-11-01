defmodule ChessWeb.Session.Server do
  use GenServer

  # Client API
  def start_link(game_id) do
    IO.inspect "Chess.Game.GameServer start_link() was called"
    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def join_game(game_id, player_id) do
    IO.inspect "Chess.Game.GameServer join_game() was called"
    GenServer.call(via_tuple(game_id), {:join_game, player_id})
  end

  def make_move(game_id, from, to) do
    IO.inspect "Chess.Game.GameServer make_move() was called"
    GenServer.call(via_tuple(game_id), {:make_move, from, to})
  end

  def get_state(game_id) do
    IO.inspect "Chess.Game.GameServer get_state() was called"
    GenServer.call(via_tuple(game_id), :get_state)
  end

  # Server Callbacks
  @impl true
  def init(game_id) do
    IO.inspect "Chess.Game.GameServer init() was called"

    {:ok, %{
      game_id: game_id,
      game_state: Chess.Board.standard(),
      players: %{
        white: nil,
        black: nil
      },
      spectators: []
    }}
  end

  @impl true
  def handle_call({:join_game, player_id}, _from, %{players: players} = state) do
    IO.inspect "Chess.Game.GameServer handl_call(:join_game) was called"

    case assign_player(players, player_id) do
      {:ok, color, new_players} ->
        {:reply, {:ok, color}, %{state | players: new_players}}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:make_move, from, to}, _from, state) do
    IO.inspect "Chess.Game.GameServer handl_call(:make_move) was called"

    with {:ok, new_game_state} <- ChessWeb.Live.GameLogic.make_move(state.game_state, from, to) do
      {:reply, {:ok, new_game_state}, %{state | game_state: new_game_state}}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    IO.inspect "Chess.Game.GameServer handle_call(:get_state) was called"

    {:reply, state, state}
  end

  # Helper Functions
  defp via_tuple(game_id) do
    IO.inspect "Chess.Game.GameServer via_tuple() was called"

    {:via, Registry, {Chess.GameRegistry, game_id}}
  end

  defp assign_player(players, player_id) do
    IO.inspect "Chess.Game.GameServer assign_player() was called"

    cond do
      players.white == player_id || players.black == player_id ->
        {:error, :already_joined}
      
      players.white == nil ->
        {:ok, :white, %{players | white: player_id}}
      
      players.black == nil ->
        {:ok, :black, %{players | black: player_id}}
      
      true ->
        {:error, :game_full}
    end
  end
end
