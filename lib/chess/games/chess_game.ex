defmodule Chess.Games.ChessGame do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chess_games" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chess_game, attrs) do
    chess_game
    |> cast(attrs, [])
    |> validate_required([])
  end
end
