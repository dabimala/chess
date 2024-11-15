defmodule ChessWeb.PageController do
  use ChessWeb, :controller

  def home(conn, _params) do
    render(conn, :index, layout: false)
  end
end
