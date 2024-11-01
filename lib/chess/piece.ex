defmodule Chess.Piece do
  defstruct color: nil,
            type: nil

  def glyphs() do
    %{:white =>
        %{:rook => "♖", :knight => "♘", :bishop => "♗", :queen => "♕", :king => "♔", :pawn => "♙"},
      :black =>
	%{:rook => "♜", :knight => "♞", :bishop => "♝", :queen => "♛", :king => "♚", :pawn => "♟"},
    }
  end

  # returns the subarray starting at index 0, and ending at the index of the
  # first element who is `diff` more than the previous element
  defp consecutive(head, diff \\ 1, tail \\ []) do
    # if there is still stuff and (tail is empty or items are still contiguous)
    if length(head) > 0 and
       (length(tail) == 0 or abs(List.first(head) - List.first(tail)) == diff) do
      {new, old} = List.pop_at(head, 0);
      consecutive(old, diff, [new | tail]);
    else
      Enum.reverse(tail);
    end
  end

  def possible_moves(%Chess.Board{cells: cells},
                     %Chess.Piece{color: _color, type: :king},
                     {xloc, yloc}) do
    # king can move to any one (1) adjacent space
    Enum.filter([
      {xloc + 0, yloc + 1},
      {xloc + 1, yloc + 1},
      {xloc + 1, yloc + 0},
      {xloc + 1, yloc - 1},
      {xloc + 0, yloc - 1},
      {xloc - 1, yloc - 1},
      {xloc - 1, yloc + 0},
      {xloc - 1, yloc + 1},
    ],
      fn neighbor ->
	Map.has_key?(cells, neighbor) and
	(cells[neighbor] == nil)
#	(cells[neighbor] == nil or cells[neighbor].color != color)
      end)
  end

  def possible_moves(%Chess.Board{width: width, height: height, cells: cells},
                     %Chess.Piece{type: :rook}, {xloc, yloc}) do
    # for each direction make a list of adjacent empty squares, including the
    # starting position
    up    = consecutive([yloc] ++ for y <- yloc..0//-1, cells[{xloc, y}] == nil, do: y)
    down  = consecutive([yloc] ++ for y <- yloc..(height - 1), cells[{xloc, y}] == nil, do: y)
    left  = consecutive([xloc] ++ for x <- xloc..0//-1, cells[{x, yloc}] == nil, do: x)
    right = consecutive([xloc] ++ for x <- xloc..(width - 1), cells[{x, yloc}] == nil, do: x)

    # add check at end of each path for capturable piece

    Enum.uniq(
      for y <- up ++ down do
	{xloc, y}
      end ++
      for x <- left ++ right do
	{x, yloc}
      end
    )
  end

  def possible_moves(%Chess.Board{width: _width, height: _height, cells: _cells},
                     %Chess.Piece{color: _color, type: :bishop},
                     _location) do
    IO.puts "Chess.Piece.possible_moves(:bishop) was called"
    []
  end

  def possible_moves(%Chess.Board{width: _width, height: _height, cells: _cells},
                     %Chess.Piece{color: _color, type: :queen},
                     _location) do
    IO.puts "Chess.Piece.possible_moves(:queen) was called"
    []
  end

  def possible_moves(%Chess.Board{width: _width, height: _height, cells: cells},
                     %Chess.Piece{color: _color, type: :knight},
                     {xloc, yloc}) do
    Enum.filter([
      {xloc + 2, yloc + 1}, {xloc + 2, yloc - 1},
      {xloc - 2, yloc + 1}, {xloc - 2, yloc - 1},
      {xloc + 1, yloc + 2}, {xloc + 1, yloc - 2},
      {xloc - 1, yloc + 2}, {xloc - 1, yloc - 2}
    ],
      fn neighbor ->
	Map.has_key?(cells, neighbor) and
	(cells[neighbor] == nil)
#	(cells[neighbor] == nil or cells[neighbor].color != color)
      end)
  end

  def possible_moves(%Chess.Board{width: _width, height: _height, cells: cells},
                     %Chess.Piece{color: color, type: :pawn},
                     {x, y}) do
    direction = if color == :white, do: -1, else: 1  # White moves up (-1), Black moves down (+1)
    start_row = if color == :white, do: 6, else: 1   # White pawns start at row 6, Black at row 1

    #IO.puts("Calculating pawn moves:")
    #IO.inspect({x, y}, label: "Current position")
    #IO.inspect(color, label: "Color")
    #IO.inspect(start_row, label: "Start row")
    #IO.inspect(direction, label: "Direction")

    # Basic forward move
    forward_moves =
    if Map.has_key?(cells, {x, y + direction}) and cells[{x, y + direction}] == nil do
      # One square forward
      one_forward = {x, y + direction}
      #IO.inspect(one_forward, label: "One square forward")
      moves = [one_forward]
      
      # Two squares forward from starting position
      if x == start_row do  # Changed from y == start_row to x == start_row
        two_forward = {x, y + (direction * 2)}  # Changed coordinate calculation
        is_empty = Map.has_key?(cells, two_forward) and cells[two_forward] == nil
        #IO.inspect(two_forward, label: "Two squares forward")
        #IO.inspect(is_empty, label: "Two squares forward is empty")
        if is_empty do
          [two_forward | moves]
        else
          moves
        end
      else
        moves
      end
    else
      #IO.puts("Forward square is not empty")
      []
    end

    #IO.inspect(forward_moves, label: "Forward moves before filtering")
    Enum.uniq([{x, y}] ++ forward_moves)

    # Capture moves
#    possible_captures = [{x + direction, y - 1}, {x + direction, y + 1}]  # Updated capture coordinates
#    #IO.inspect(possible_captures, label: "Possible capture positions")
    
#    capture_moves =
#      possible_captures
#      |> Enum.filter(fn pos -> 
#      can_capture = can_capture?(board, pos, color)
#      #IO.inspect({pos, can_capture}, label: "Capture check")
#      can_capture
#    end)
#
#      #IO.inspect(capture_moves, label: "Valid capture moves")
#
#      all_moves = forward_moves ++ capture_moves
#      valid_moves = Enum.filter(all_moves, &valid_position?/1)
#      
#      #IO.inspect(valid_moves, label: "Final valid moves")
#      valid_moves
  end
end
