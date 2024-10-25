defmodule Chess.Move do
  use Ecto.Schema
  import Ecto.Changeset

  schema "moves" do
    field :move_notation, :string
    field :move_number, :integer
    field :game_id, :id
    field :player_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(move, attrs) do
    move
    |> cast(attrs, [:move_notation, :move_number])
    |> validate_required([:move_notation, :move_number])
  end
end
