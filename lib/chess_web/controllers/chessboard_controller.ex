defmodule ChessWeb.ChessboardController do
  use ChessWeb, :controller

  def chess(conn, _params) do
    render(conn, :chessboard, layout: false)
  end
end
