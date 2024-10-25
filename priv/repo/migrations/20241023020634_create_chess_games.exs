defmodule Chess.Repo.Migrations.CreateChessGames do
  use Ecto.Migration

  def change do
    create table(:chess_games) do

      timestamps(type: :utc_datetime)
    end
  end
end
