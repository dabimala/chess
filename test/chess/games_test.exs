defmodule Chess.GamesTest do
  use Chess.DataCase

  alias Chess.Games

  describe "chess_games" do
    alias Chess.Games.ChessGame

    import Chess.GamesFixtures

    @invalid_attrs %{}

    test "list_chess_games/0 returns all chess_games" do
      chess_game = chess_game_fixture()
      assert Games.list_chess_games() == [chess_game]
    end

    test "get_chess_game!/1 returns the chess_game with given id" do
      chess_game = chess_game_fixture()
      assert Games.get_chess_game!(chess_game.id) == chess_game
    end

    test "create_chess_game/1 with valid data creates a chess_game" do
      valid_attrs = %{}

      assert {:ok, %ChessGame{} = chess_game} = Games.create_chess_game(valid_attrs)
    end

    test "create_chess_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_chess_game(@invalid_attrs)
    end

    test "update_chess_game/2 with valid data updates the chess_game" do
      chess_game = chess_game_fixture()
      update_attrs = %{}

      assert {:ok, %ChessGame{} = chess_game} = Games.update_chess_game(chess_game, update_attrs)
    end

    test "update_chess_game/2 with invalid data returns error changeset" do
      chess_game = chess_game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_chess_game(chess_game, @invalid_attrs)
      assert chess_game == Games.get_chess_game!(chess_game.id)
    end

    test "delete_chess_game/1 deletes the chess_game" do
      chess_game = chess_game_fixture()
      assert {:ok, %ChessGame{}} = Games.delete_chess_game(chess_game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_chess_game!(chess_game.id) end
    end

    test "change_chess_game/1 returns a chess_game changeset" do
      chess_game = chess_game_fixture()
      assert %Ecto.Changeset{} = Games.change_chess_game(chess_game)
    end
  end
end
