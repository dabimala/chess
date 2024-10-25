defmodule Chess.Game.Logic do
  def new_game do
    %{
      board: initial_board(),
      current_player: :white,
      selected_square: nil,
      valid_moves: []
    }
  end

  def initial_board do
    %{
      # Black pieces
      {0, 0} => "bR", {0, 1} => "bN", {0, 2} => "bB", {0, 3} => "bQ",
      {0, 4} => "bK", {0, 5} => "bB", {0, 6} => "bN", {0, 7} => "bR",
      # Black pawns
      {1, 0} => "bP", {1, 1} => "bP", {1, 2} => "bP", {1, 3} => "bP",
      {1, 4} => "bP", {1, 5} => "bP", {1, 6} => "bP", {1, 7} => "bP",
      # White pawns
      {6, 0} => "wP", {6, 1} => "wP", {6, 2} => "wP", {6, 3} => "wP",
      {6, 4} => "wP", {6, 5} => "wP", {6, 6} => "wP", {6, 7} => "wP",
      # White pieces
      {7, 0} => "wR", {7, 1} => "wN", {7, 2} => "wB", {7, 3} => "wQ",
      {7, 4} => "wK", {7, 5} => "wB", {7, 6} => "wN", {7, 7} => "wR"
    }
  end
end
