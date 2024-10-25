defmodule ChessWeb.ChessGameHTML do
  use ChessWeb, :html

  embed_templates "chess_game_html/*"

  @doc """
  Renders a chess_game form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def chess_game_form(assigns)
end
