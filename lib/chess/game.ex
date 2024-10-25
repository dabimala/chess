defmodule Chess.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :status, :string
    field :board_state, :map
    field :turn, :string
    field :player1_id, :id
    field :player2_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:board_state, :turn, :status])
    |> validate_required([:turn, :status])
  end
end
