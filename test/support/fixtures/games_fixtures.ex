defmodule Chess.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chess.Games` context.
  """

  @doc """
  Generate a chess_game.
  """
  def chess_game_fixture(attrs \\ %{}) do
    {:ok, chess_game} =
      attrs
      |> Enum.into(%{

      })
      |> Chess.Games.create_chess_game()

    chess_game
  end
end
