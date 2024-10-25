defmodule Chess.Repo.Migrations.CreateMoves do
  use Ecto.Migration

  def change do
    create table(:moves) do
      add :move_notation, :string
      add :move_number, :integer
      add :game_id, references(:games, on_delete: :nothing)
      add :player_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:moves, [:game_id])
    create index(:moves, [:player_id])
  end
end
