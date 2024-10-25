defmodule ChessWeb.ChessboardHTML do
  @moduledoc """
  This module contains pages rendered by ChessboardController.

  See the `chess_board.html` directory for all templates available.
  """
  use ChessWeb, :html

  embed_templates "chess_board_html/*"
end
