defmodule ChessWeb.Live.GameLogic do
  require Logger

  @type position :: {integer, integer}
  @type piece :: {String.t(), position}
  @type board :: %{position => String.t()}

  def valid_moves(board, {x, y} = position) do
    case Map.get(board.cells, position) do
      %Chess.Piece{type: type, color: color} ->
        case type do
          :pawn -> pawn_moves(board, position, color)
          :rook -> rook_moves(board, position, color)
          :knight -> knight_moves(board, position, color)
          :bishop -> bishop_moves(board, position, color)
          :queen -> queen_moves(board, position, color)
          :king -> king_moves(board, position, color)
        end
      _ -> []
    end
  end

  defp pawn_moves(board, {row, col}, color) do
    direction = if color == :white, do: -1, else: 1
    start_col = if color == :white, do: 6, else: 1

    IO.puts("\n=== Pawn Move Calculation ===")
    IO.inspect({row, col, color}, label: "Calculating pawn moves")

    # Forward moves
    forward_moves = get_forward_moves(board, {row, col}, direction, start_col)
    capture_moves = get_capture_moves(board, {row, col}, direction, color)
    
    all_moves = forward_moves ++ capture_moves
    IO.inspect(all_moves, label: "All valid pawn moves")
    all_moves
  end

  defp get_forward_moves(board, {row, col}, direction, start_col) do
    one_forward = {row, col + direction}

    if valid_position?(one_forward) && empty_position?(board, one_forward) do
      moves = [one_forward]
      
      if col == start_col do
        two_forward = {row, col + (2 * direction)}
        if valid_position?(two_forward) && empty_position?(board, two_forward) do
          [two_forward | moves]
        else
          moves
        end
      else
        moves
      end
    else
      []
    end
  end

  defp get_capture_moves(board, {row, col}, direction, color) do
    [{row - 1, col + direction}, {row + 1, col + direction}]
    |> Enum.filter(fn pos ->
      valid_position?(pos) && can_capture?(board, pos, color)
    end)
  end

  defp rook_moves(board, {row, col}, color) do
    IO.puts("\n=== Rook Move Calculation ===")
    
    # Horizontal and vertical directions
    directions = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    moves = sliding_moves(board, {row, col}, color, directions)
    
    IO.inspect(moves, label: "Valid rook moves")
    moves
  end

  defp knight_moves(board, {row, col}, color) do
    IO.puts("\n=== Knight Move Calculation ===")
    
    moves = [
      {row + 2, col + 1}, {row + 2, col - 1},
      {row - 2, col + 1}, {row - 2, col - 1},
      {row + 1, col + 2}, {row + 1, col - 2},
      {row - 1, col + 2}, {row - 1, col - 2}
    ]
    |> Enum.filter(&valid_position?/1)
    |> Enum.filter(fn pos ->
      empty_position?(board, pos) || can_capture?(board, pos, color)
    end)
    
    IO.inspect(moves, label: "Valid knight moves")
    moves
  end

  defp bishop_moves(board, {row, col}, color) do
    IO.puts("\n=== Bishop Move Calculation ===")
    
    # Diagonal directions
    directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
    moves = sliding_moves(board, {row, col}, color, directions)
    
    IO.inspect(moves, label: "Valid bishop moves")
    moves
  end

  defp queen_moves(board, {row, col}, color) do
    IO.puts("\n=== Queen Move Calculation ===")
    
    # All directions (combination of rook and bishop)
    directions = [
      {0, 1}, {0, -1}, {1, 0}, {-1, 0},
      {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
    ]
    moves = sliding_moves(board, {row, col}, color, directions)
    
    IO.inspect(moves, label: "Valid queen moves")
    moves
  end

  defp king_moves(board, {row, col}, color) do
    IO.puts("\n=== King Move Calculation ===")
    
    moves = [
      {row, col + 1}, {row, col - 1},
      {row + 1, col}, {row - 1, col},
      {row + 1, col + 1}, {row + 1, col - 1},
      {row - 1, col + 1}, {row - 1, col - 1}
    ]
    |> Enum.filter(&valid_position?/1)
    |> Enum.filter(fn pos ->
      empty_position?(board, pos) || can_capture?(board, pos, color)
    end)
    
    IO.inspect(moves, label: "Valid king moves")
    moves
  end

  defp sliding_moves(board, {row, col}, color, directions) do
    Enum.flat_map(directions, fn {dx, dy} ->
      generate_line_moves(board, {row, col}, {dx, dy}, color)
    end)
  end

  defp generate_line_moves(board, {row, col}, {dx, dy}, color, acc \\ []) do
    next_pos = {row + dx, col + dy}

    cond do
      !valid_position?(next_pos) ->
        acc
      empty_position?(board, next_pos) ->
        generate_line_moves(board, next_pos, {dx, dy}, color, [next_pos | acc])
      can_capture?(board, next_pos, color) ->
        [next_pos | acc]
      true ->
        acc
    end
  end

  defp valid_position?({row, col}) do
    row >= 0 && row < 8 && col >= 0 && col < 8
  end

  defp empty_position?(board, pos) do
    board.cells[pos] == nil
  end

  defp can_capture?(board, pos, attacking_color) do
    case board.cells[pos] do
      nil -> false
      piece -> piece.color != attacking_color
    end
  end

  def valid_move?(board, from, to) do
    case Map.get(board.cells, from) do
      nil -> false
      piece -> to in valid_moves(board, from)
    end
  end

  def make_move(board, from, to) do
    if valid_move?(board, from, to) do
      piece = board.cells[from]
      %{board | cells: Map.put(Map.delete(board.cells, from), to, piece)}
    else
      board
    end
  end
end
