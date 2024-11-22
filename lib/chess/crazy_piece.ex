defmodule Chess.CrazyPiece do
  require Logger

  # Update the struct definition with the new field
  @enforce_keys [:color, :type, :has_moved]
  defstruct [:color, :type, :has_moved]

  def glyphs do
    %{:white =>
        %{:dragon => "🐉",    
          :wizard => "🧙‍♂️",    
          :ninja => "🥷",     
          :phoenix => "🦅",   
          :pawn => "♙",      
          :king => "♔"},     
      :black =>
        %{:dragon => "🐲",    # Changed to green dragon
          :wizard => "🧙🏿‍♂️",   # Changed to dark skin tone wizard
          :ninja => "👤",     # Changed to silhouette
          :phoenix => "🦢",   # Changed to black swan
          :pawn => "♟",
          :king => "♚"}
    }
  end

  # Helper function to create a new piece
  def new(type, color) do
    %__MODULE__{
      type: type,
      color: color,
      has_moved: false
    }
  end

  # Dragon movements (Queen + Knight)
  def possible_moves(%Chess.CrazyBoard{cells: cells},
                    %Chess.CrazyPiece{type: :dragon, color: color},
                    {row, col}) do
    Logger.info("Calculating Dragon moves from {#{row}, #{col}}")
    queen_moves = get_queen_moves(cells, {row, col}, color)
    knight_moves = get_knight_moves(cells, {row, col}, color)
    moves = Enum.uniq(queen_moves ++ knight_moves)
    Logger.info("Dragon can move to: #{inspect(moves)}")
    moves
  end

  # Wizard movements (Teleport anywhere empty or capturable)
  def possible_moves(%Chess.CrazyBoard{cells: cells},
                    %Chess.CrazyPiece{type: :wizard, color: color, has_moved: has_moved},
                    {row, col}) do
    Logger.info("Calculating Wizard moves from {#{row}, #{col}}")
    moves = if has_moved do
      # After first move - can move to any square not occupied by friendly piece
      for r <- 0..7,
          c <- 0..7,
          {r, c} != {row, col},
          cells[{r, c}] == nil || cells[{r, c}].color != color,
          do: {r, c}
    else
      # First move - can only move to empty squares
      for r <- 0..7,
          c <- 0..7,
          {r, c} != {row, col},
          cells[{r, c}] == nil,
          do: {r, c}
    end
    Logger.info("Wizard can move to: #{inspect(moves)}")
    moves
  end

  # Ninja movements (Knight + Adjacent)
  def possible_moves(%Chess.CrazyBoard{cells: cells},
                    %Chess.CrazyPiece{type: :ninja, color: color},
                    {row, col}) do
    Logger.info("Calculating Ninja moves from {#{row}, #{col}}")
    knight_moves = get_knight_moves(cells, {row, col}, color)
    adjacent_moves = get_adjacent_moves(cells, {row, col}, color)
    moves = Enum.uniq(knight_moves ++ adjacent_moves)
    Logger.info("Ninja can move to: #{inspect(moves)}")
    moves
  end

  # Phoenix movements (Jumping diagonals)
  def possible_moves(%Chess.CrazyBoard{cells: cells},
                    %Chess.CrazyPiece{type: :phoenix, color: color},
                    {row, col}) do
    Logger.info("Calculating Phoenix moves from {#{row}, #{col}}")
    moves = get_diagonal_jumping_moves(cells, {row, col}, color)
    Logger.info("Phoenix can move to: #{inspect(moves)}")
    moves
  end

  # King movements (One square in any direction)
  def possible_moves(%Chess.CrazyBoard{cells: cells},
                    %Chess.CrazyPiece{type: :king, color: color},
                    {row, col}) do
    Logger.info("Calculating King moves from {#{row}, #{col}}")
    moves = get_adjacent_moves(cells, {row, col}, color)
    Logger.info("King can move to: #{inspect(moves)}")
    moves
  end

  # Pawn movements
  def possible_moves(%Chess.CrazyBoard{cells: cells},
                    %Chess.CrazyPiece{type: :pawn, color: color},
                    {row, col}) do
    Logger.info("Calculating Pawn moves from {#{row}, #{col}}")
    direction = if color == :white, do: -1, else: 1
    start_col = if color == :white, do: 6, else: 1

    # Forward moves
    forward_moves = 
      if valid_position?({row, col + direction}) && cells[{row, col + direction}] == nil do
        moves = [{row, col + direction}]
        if col == start_col && 
           valid_position?({row, col + (direction * 2)}) && 
           cells[{row, col + (direction * 2)}] == nil do
          [{row, col + (direction * 2)} | moves]
        else
          moves
        end
      else
        []
      end

    # Capture moves
    capture_moves =
      [{row - 1, col + direction}, {row + 1, col + direction}]
      |> Enum.filter(fn pos ->
        valid_position?(pos) &&
          cells[pos] != nil &&
          cells[pos].color != color
      end)

    moves = forward_moves ++ capture_moves
    Logger.info("Pawn can move to: #{inspect(moves)}")
    moves
  end

  # Helper functions remain the same
  defp get_queen_moves(cells, {row, col}, color) do
    directions = [
      {-1, -1}, {-1, 0}, {-1, 1},
      {0, -1},           {0, 1},
      {1, -1},  {1, 0},  {1, 1}
    ]
    
    Enum.flat_map(directions, fn {dr, dc} ->
      get_line_moves(cells, {row, col}, {dr, dc}, color)
    end)
  end

  defp get_knight_moves(cells, {row, col}, color) do
    [
      {row + 2, col + 1}, {row + 2, col - 1},
      {row - 2, col + 1}, {row - 2, col - 1},
      {row + 1, col + 2}, {row + 1, col - 2},
      {row - 1, col + 2}, {row - 1, col - 2}
    ]
    |> Enum.filter(fn pos ->
      valid_position?(pos) && (cells[pos] == nil || cells[pos].color != color)
    end)
  end

  defp get_adjacent_moves(cells, {row, col}, color) do
    [
      {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
      {row, col - 1},                     {row, col + 1},
      {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}
    ]
    |> Enum.filter(fn pos ->
      valid_position?(pos) && (cells[pos] == nil || cells[pos].color != color)
    end)
  end

  defp get_diagonal_jumping_moves(cells, {row, col}, color) do
    directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
    
    Enum.flat_map(directions, fn {dr, dc} = dir ->
      Logger.info("Phoenix checking direction #{inspect(dir)}")
      moves = get_phoenix_line(cells, {row, col}, {dr, dc}, color)
      Logger.info("Phoenix moves in direction #{inspect(dir)}: #{inspect(moves)}")
      moves
    end)
  end

  defp get_line_moves(cells, {row, col}, {dr, dc}, color, acc \\ []) do
    new_pos = {row + dr, col + dc}
    
    cond do
      !valid_position?(new_pos) -> 
        acc
      cells[new_pos] == nil ->
        get_line_moves(cells, new_pos, {dr, dc}, color, [new_pos | acc])
      cells[new_pos].color != color -> 
        [new_pos | acc]
      true -> 
        acc
    end
  end

  defp get_phoenix_line(cells, {row, col}, {dr, dc}, color, acc \\ []) do
    new_pos = {row + dr, col + dc}
    
    cond do
      !valid_position?(new_pos) ->
        Enum.reverse(acc)
      true ->
        case cells[new_pos] do
          nil ->
            get_phoenix_line(cells, new_pos, {dr, dc}, color, [new_pos | acc])
          piece when piece.color != color ->
            get_phoenix_line(cells, new_pos, {dr, dc}, color, [new_pos | acc])
          _piece ->
            get_phoenix_line(cells, new_pos, {dr, dc}, color, acc)
        end
    end
  end

  defp valid_position?({row, col}) do
    row >= 0 && row < 8 && col >= 0 && col < 8
  end
end
