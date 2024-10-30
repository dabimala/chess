defmodule ChessWeb.ChessGameController do
  use ChessWeb, :controller
  alias Chess.GameState  # Changed from Game to GameState
  alias Chess.Games
  alias Chess.Games.ChessGame

  def index(conn, _params) do
    game = GameState.new_game()
    render(conn, :index, game: game)
  end

  def make_move(conn, %{"from" => from, "to" => to}) do
    {from_row, from_col} = parse_coordinates(from)
    {to_row, to_col} = parse_coordinates(to)
    game = GameState.new_game() # Changed from Game.new_game()
    
    # Updated to handle the new return type from make_move
#    new_game = GameState.make_move(game, {from_row, from_col}, {to_row, to_col})
    new_game = ChessWeb.Live.GameLive.GameLogic.make_move(game, {from_row, from_col}, {to_row, to_col})
    case new_game do
      %Chess.GameState{} = updated_game ->
        json(conn, %{status: "ok", board: updated_game.board})
      {:error, reason} ->
        json(conn, %{status: "error", reason: reason})
    end
  end

  defp parse_coordinates(coordinate) do
    [row, col] = String.split(coordinate, ",") |> Enum.map(&String.to_integer/1)
    {row, col}
  end

  def new(conn, _params) do
    changeset = Games.change_chess_game(%ChessGame{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"chess_game" => chess_game_params}) do
    case Games.create_chess_game(chess_game_params) do
      {:ok, chess_game} ->
        conn
        |> put_flash(:info, "Chess game created successfully.")
        |> redirect(to: ~p"/play/#{chess_game}")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    chess_game = Games.get_chess_game!(id)
    render(conn, :show, chess_game: chess_game)
  end

  def edit(conn, %{"id" => id}) do
    chess_game = Games.get_chess_game!(id)
    changeset = Games.change_chess_game(chess_game)
    render(conn, :edit, chess_game: chess_game, changeset: changeset)
  end

  def update(conn, %{"id" => id, "chess_game" => chess_game_params}) do
    chess_game = Games.get_chess_game!(id)
    case Games.update_chess_game(chess_game, chess_game_params) do
      {:ok, chess_game} ->
        conn
        |> put_flash(:info, "Chess game updated successfully.")
        |> redirect(to: ~p"/play/#{chess_game}")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, chess_game: chess_game, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    chess_game = Games.get_chess_game!(id)
    {:ok, _chess_game} = Games.delete_chess_game(chess_game)  # Fixed asterisks
    conn
    |> put_flash(:info, "Chess game deleted successfully.")
    |> redirect(to: ~p"/play")
  end
end
