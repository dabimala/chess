defmodule Chess.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Chess.Repo

  alias Chess.Games.ChessGame

  @doc """
  Returns the list of chess_games.

  ## Examples

      iex> list_chess_games()
      [%ChessGame{}, ...]

  """
  def list_chess_games do
    Repo.all(ChessGame)
  end

  @doc """
  Gets a single chess_game.

  Raises `Ecto.NoResultsError` if the Chess game does not exist.

  ## Examples

      iex> get_chess_game!(123)
      %ChessGame{}

      iex> get_chess_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chess_game!(id), do: Repo.get!(ChessGame, id)

  @doc """
  Creates a chess_game.

  ## Examples

      iex> create_chess_game(%{field: value})
      {:ok, %ChessGame{}}

      iex> create_chess_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chess_game(attrs \\ %{}) do
    %ChessGame{}
    |> ChessGame.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chess_game.

  ## Examples

      iex> update_chess_game(chess_game, %{field: new_value})
      {:ok, %ChessGame{}}

      iex> update_chess_game(chess_game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chess_game(%ChessGame{} = chess_game, attrs) do
    chess_game
    |> ChessGame.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chess_game.

  ## Examples

      iex> delete_chess_game(chess_game)
      {:ok, %ChessGame{}}

      iex> delete_chess_game(chess_game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chess_game(%ChessGame{} = chess_game) do
    Repo.delete(chess_game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chess_game changes.

  ## Examples

      iex> change_chess_game(chess_game)
      %Ecto.Changeset{data: %ChessGame{}}

  """
  def change_chess_game(%ChessGame{} = chess_game, attrs \\ %{}) do
    ChessGame.changeset(chess_game, attrs)
  end
end
