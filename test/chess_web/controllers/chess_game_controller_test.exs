defmodule ChessWeb.ChessGameControllerTest do
  use ChessWeb.ConnCase

  import Chess.GamesFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all chess_games", %{conn: conn} do
      conn = get(conn, ~p"/chess_games")
      assert html_response(conn, 200) =~ "Listing Chess games"
    end
  end

  describe "new chess_game" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/chess_games/new")
      assert html_response(conn, 200) =~ "New Chess game"
    end
  end

  describe "create chess_game" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/chess_games", chess_game: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/chess_games/#{id}"

      conn = get(conn, ~p"/chess_games/#{id}")
      assert html_response(conn, 200) =~ "Chess game #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/chess_games", chess_game: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Chess game"
    end
  end

  describe "edit chess_game" do
    setup [:create_chess_game]

    test "renders form for editing chosen chess_game", %{conn: conn, chess_game: chess_game} do
      conn = get(conn, ~p"/chess_games/#{chess_game}/edit")
      assert html_response(conn, 200) =~ "Edit Chess game"
    end
  end

  describe "update chess_game" do
    setup [:create_chess_game]

    test "redirects when data is valid", %{conn: conn, chess_game: chess_game} do
      conn = put(conn, ~p"/chess_games/#{chess_game}", chess_game: @update_attrs)
      assert redirected_to(conn) == ~p"/chess_games/#{chess_game}"

      conn = get(conn, ~p"/chess_games/#{chess_game}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, chess_game: chess_game} do
      conn = put(conn, ~p"/chess_games/#{chess_game}", chess_game: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Chess game"
    end
  end

  describe "delete chess_game" do
    setup [:create_chess_game]

    test "deletes chosen chess_game", %{conn: conn, chess_game: chess_game} do
      conn = delete(conn, ~p"/chess_games/#{chess_game}")
      assert redirected_to(conn) == ~p"/chess_games"

      assert_error_sent 404, fn ->
        get(conn, ~p"/chess_games/#{chess_game}")
      end
    end
  end

  defp create_chess_game(_) do
    chess_game = chess_game_fixture()
    %{chess_game: chess_game}
  end
end
