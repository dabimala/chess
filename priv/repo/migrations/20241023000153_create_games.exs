defmodule Chess.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :board_state, :map
      add :turn, :string
      add :status, :string
      add :player1_id, references(:users, on_delete: :nothing)
      add :player2_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:games, [:player1_id])
    create index(:games, [:player2_id])
  end
end
