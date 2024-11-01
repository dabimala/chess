defmodule ChessWeb.Live.GameLogic do
  @type position :: {integer, integer}
  @type piece :: {String.t(), position}
  @type board :: %{position => String.t()}

  @doc """
  Gets valid moves for a piece at the given position.
  Returns a list of valid positions the piece can move to.
  """
  def valid_moves(board, {x, y} = _position) do
    case Map.get(board, {x, y}) do
      "wP" -> pawn_moves(board, {x, y}, :white)
      "bP" -> pawn_moves(board, {x, y}, :black)
      "wR" -> rook_moves(board, {x, y}, :white)
      "bR" -> rook_moves(board, {x, y}, :black)
      "wN" -> knight_moves(board, {x, y}, :white)
      "bN" -> knight_moves(board, {x, y}, :black)
      "wB" -> bishop_moves(board, {x, y}, :white)
      "bB" -> bishop_moves(board, {x, y}, :black)
      "wQ" -> queen_moves(board, {x, y}, :white)
      "bQ" -> queen_moves(board, {x, y}, :black)
      "wK" -> king_moves(board, {x, y}, :white)
      "bK" -> king_moves(board, {x, y}, :black)
      _ -> []
    end
  end

  @doc """
  Checks if a move is valid for the given piece.
  """
  def valid_move?(board, from, to) do
    valid_moves(board, from)
    |> Enum.member?(to)
  end

  # Movement patterns for each piece type
  
  #Pawn Moves
  defp pawn_moves(board, {x, y}, color) do
    direction = if color == :white, do: -1, else: 1  # White moves up (-1), Black moves down (+1)
    start_row = if color == :white, do: 6, else: 1   # White pawns start at row 6, Black at row 1

    IO.puts("Calculating pawn moves:")
    IO.inspect({x, y}, label: "Current position")
    IO.inspect(color, label: "Color")
    IO.inspect(start_row, label: "Start row")
    IO.inspect(direction, label: "Direction")

    # Basic forward move
    forward_moves =
    if empty_square?(board, {x + direction, y}) do  # Changed from y + direction to x + direction
      # One square forward
      one_forward = {x + direction, y}  # Changed from y + direction to x + direction
      IO.inspect(one_forward, label: "One square forward")
      moves = [one_forward]
      
      # Two squares forward from starting position
      if x == start_row do  # Changed from y == start_row to x == start_row
        two_forward = {x + (direction * 2), y}  # Changed coordinate calculation
        is_empty = empty_square?(board, two_forward)
        IO.inspect(two_forward, label: "Two squares forward")
        IO.inspect(is_empty, label: "Two squares forward is empty")
        if is_empty do
          [two_forward | moves]
        else
          moves
        end
      else
        moves
      end
    else
      IO.puts("Forward square is not empty")
      []
    end

    IO.inspect(forward_moves, label: "Forward moves before filtering")

    # Capture moves
    possible_captures = [{x + direction, y - 1}, {x + direction, y + 1}]  # Updated capture coordinates
    IO.inspect(possible_captures, label: "Possible capture positions")
    
    capture_moves =
      possible_captures
      |> Enum.filter(fn pos -> 
      can_capture = can_capture?(board, pos, color)
      IO.inspect({pos, can_capture}, label: "Capture check")
      can_capture
    end)

      IO.inspect(capture_moves, label: "Valid capture moves")

      all_moves = forward_moves ++ capture_moves
      valid_moves = Enum.filter(all_moves, &valid_position?/1)
      
      IO.inspect(valid_moves, label: "Final valid moves")
      valid_moves
  end

  #Rook Moves
  defp rook_moves(board, {x, y}, color) do
    directions = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    sliding_moves(board, {x, y}, color, directions)
  end
 
 #Knight Moves
  defp knight_moves(board, {x, y}, color) do
    [
      {x + 2, y + 1}, {x + 2, y - 1},
      {x - 2, y + 1}, {x - 2, y - 1},
      {x + 1, y + 2}, {x + 1, y - 2},
      {x - 1, y + 2}, {x - 1, y - 2}
    ]
    |> Enum.filter(&valid_position?/1)
    |> Enum.filter(fn pos -> 
      empty_square?(board, pos) || can_capture?(board, pos, color)
    end)
  end
  
  #Bishop Moves
  defp bishop_moves(board, {x, y}, color) do
    directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
    sliding_moves(board, {x, y}, color, directions)
  end

  #Queen Moves
  defp queen_moves(board, {x, y}, color) do
    directions = [
      {0, 1}, {0, -1}, {1, 0}, {-1, 0},
      {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
    ]
    sliding_moves(board, {x, y}, color, directions)
  end
 
  #King Moves
  defp king_moves(board, {x, y}, color) do
    [
      {x + 1, y}, {x - 1, y},
      {x, y + 1}, {x, y - 1},
      {x + 1, y + 1}, {x + 1, y - 1},
      {x - 1, y + 1}, {x - 1, y - 1}
    ]
    |> Enum.filter(&valid_position?/1)
    |> Enum.filter(fn pos -> 
      empty_square?(board, pos) || can_capture?(board, pos, color)
    end)
  end

  # Helper functions
  defp sliding_moves(board, {x, y}, color, directions) do
    Enum.flat_map(directions, fn {dx, dy} ->
      generate_line_moves(board, {x, y}, {dx, dy}, color)
    end)
  end

  defp generate_line_moves(board, {x, y}, {dx, dy}, color, acc \\ []) do
    next_pos = {x + dx, y + dy}

    cond do
      !valid_position?(next_pos) ->
        acc

      empty_square?(board, next_pos) ->
        generate_line_moves(board, next_pos, {dx, dy}, color, [next_pos | acc])

      can_capture?(board, next_pos, color) ->
        [next_pos | acc]

      true ->
        acc
    end
  end

  defp valid_position?({x, y}) do
  result = x >= 0 && x < 8 && y >= 0 && y < 8
  IO.inspect({{x, y}, result}, label: "Position validity check")
  result
end

defp empty_square?(board, pos) do
  result = !Map.has_key?(board, pos)
  IO.inspect({pos, result}, label: "Empty square check")
  result
end

defp can_capture?(board, pos, color) do
  result = case Map.get(board, pos) do
    nil -> false
    piece ->
      piece_color = if String.starts_with?(piece, "w"), do: :white, else: :black
      piece_color != color
  end
  IO.inspect({pos, color, result}, label: "Capture check")
  result
end
  @doc """
  Makes a move on the board and returns the new board state.
  """
  def make_move(board, from, to) do
    if valid_move?(board, from, to) do
      piece = Map.get(board, from)
      board
      |> Map.delete(from)
      |> Map.put(to, piece)
    else
      board
    end
  end

  @doc """
  Gets the color of the piece at the given position.
  """
  def piece_color(piece) when is_binary(piece) do
    case String.first(piece) do
      "w" -> :white
      "b" -> :black
      _ -> nil
    end
  end
end
