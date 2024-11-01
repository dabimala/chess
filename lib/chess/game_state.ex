defmodule Chess.GameState do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    :ets.new(:chess_games, [:set, :public, :named_table])
    {:ok, %{}}
  end

  def get_game(id) do
    GenServer.call(__MODULE__, {:get_game, id})
  end

  def create_game(id, state) do
    GenServer.cast(__MODULE__, {:create_game, id, state})
  end

  @impl true
  def handle_call({:get_game, id}, _from, state) do
    result = case :ets.lookup(:chess_games, id) do
      [{^id, game_state}] -> game_state
      [] -> nil
    end
    {:reply, result, state}
  end

  @impl true
  def handle_cast({:create_game, id, game_state}, state) do
    :ets.insert(:chess_games, {id, game_state})
    {:noreply, state}
  end
end
