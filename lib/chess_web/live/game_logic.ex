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

  def valid_moves(board, piece, position) when is_tuple(position) do
    case piece do
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

  def game_over?(board, color) do
    cond do
      find_king(board, color) == nil -> {:checkmate, color}
      checkmate?(board, color) -> {:checkmate, color}
      stalemate?(board, color) -> {:stalemate, color}
      insufficient_material?(board) -> {:draw, :insufficient_material}
      true -> false
    end
  end

  def checkmate?(board, color) do
    case find_king(board, color) do
      nil -> true
      _king_pos -> in_check?(board, color) && no_valid_moves?(board, color)
    end
  end

  def stalemate?(board, color) do
    !in_check?(board, color) && no_valid_moves?(board, color)
  end

  def in_check?(board, color) do
    case find_king(board, color) do
      nil -> true
      king_pos ->
        opponent_color = if color == :white, do: :black, else: :white
        opponent_pieces = find_pieces(board, opponent_color)
        Enum.any?(opponent_pieces, fn {pos, _piece} ->
          king_pos in valid_moves(board, pos)
        end)
    end
  end

  defp no_valid_moves?(board, color) do
    pieces = find_pieces(board, color)
    !Enum.any?(pieces, fn {pos, _piece} ->
      valid_moves(board, pos) != []
    end)
  end

  defp find_king(board, color) do
    case board.cells
         |> Enum.find(fn {_pos, piece} -> 
           piece && piece.type == :king && piece.color == color 
         end) do
      nil -> nil
      found_king -> elem(found_king, 0)
    end
  end

  defp find_pieces(board, color) do
    board.cells
    |> Enum.filter(fn {_pos, piece} -> 
      piece && piece.color == color 
    end)
  end

  defp insufficient_material?(board) do
    pieces = Enum.filter(board.cells, fn {_pos, piece} -> piece != nil end)
    
    case length(pieces) do
      2 -> true  # Just kings
      3 -> # King and bishop, or king and knight
        pieces |> Enum.any?(fn {_pos, piece} -> 
          piece.type == :bishop || piece.type == :knight
        end)
      _ -> false
    end
  end

  defp pawn_moves(board, {row, col}, color) do
    direction = if color == :white, do: -1, else: 1
    start_col = if color == :white, do: 6, else: 1

    Logger.debug("\n=== Pawn Move Calculation ===")
    Logger.debug("Calculating pawn moves")

    forward_moves = get_forward_moves(board, {row, col}, direction, start_col)
    capture_moves = get_capture_moves(board, {row, col}, direction, color)

    all_moves = forward_moves ++ capture_moves
    Logger.debug("All valid pawn moves: #{inspect(all_moves)}")
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
    Logger.debug("\n=== Rook Move Calculation ===")
    directions = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    moves = sliding_moves(board, {row, col}, color, directions)
    Logger.debug("Valid rook moves: #{inspect(moves)}")
    moves
  end

  defp knight_moves(board, {row, col}, color) do
    Logger.debug("\n=== Knight Move Calculation ===")
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
    Logger.debug("Valid knight moves: #{inspect(moves)}")
    moves
  end

  defp bishop_moves(board, {row, col}, color) do
    Logger.debug("\n=== Bishop Move Calculation ===")
    directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
    moves = sliding_moves(board, {row, col}, color, directions)
    Logger.debug("Valid bishop moves: #{inspect(moves)}")
    moves
  end

  defp queen_moves(board, {row, col}, color) do
    Logger.debug("\n=== Queen Move Calculation ===")
    directions = [
      {0, 1}, {0, -1}, {1, 0}, {-1, 0},
      {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
    ]
    moves = sliding_moves(board, {row, col}, color, directions)
    Logger.debug("Valid queen moves: #{inspect(moves)}")
    moves
  end

  defp king_moves(board, {row, col}, color) do
    Logger.debug("\n=== King Move Calculation ===")
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
    Logger.debug("Valid king moves: #{inspect(moves)}")
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
      piece ->
        to in valid_moves(board, from) && 
          (empty_position?(board, to) || can_capture?(board, to, piece.color))
    end
  end

  def make_move(board, from, to) do
    case Map.get(board.cells, from) do
      nil -> board
      piece ->
        if valid_move?(board, from, to) do
          captured_piece = board.cells[to]
          new_cells = board.cells
                     |> Map.delete(from)
                     |> Map.put(to, piece)
          %{board | cells: new_cells}
        else
          board
        end
    end
  end
end
