defmodule Chess.Board do
  defstruct width: nil,
            height: nil,
            cells: %{},  # {coordinate} => %Chess.Piece{}
            capture_piles: %{black: [], white: []},  # Capture piles for both colors
            move_history: [],  # For threefold repetition
            moves_since_capture: 0  # For fifty-move rule

  # Modified make_move to track moves and update history

  def make_move(board = %Chess.Board{cells: cells, capture_piles: capture_piles}, to, from) do
    if to == from do
      board
    else
      piece_to_capture = cells[to]
      moves_since_capture = board.moves_since_capture

      # Handle capture and move counter updates
      {updated_captures, new_moves_since_capture} = 
        if piece_to_capture != nil and piece_to_capture.color != cells[from].color do
          {capture_piece(capture_piles, piece_to_capture), 0}
        else
          {capture_piles, moves_since_capture + 1}
        end

      # Store the current position in history
      updated_history = [cells | board.move_history]

      # Move the piece and update all board state
      %{board | 
        cells: %{cells | to => cells[from], from => nil},
        capture_piles: updated_captures,
        move_history: updated_history,
        moves_since_capture: new_moves_since_capture
      }
    end
  end

  # Existing capture_piece function
  defp capture_piece(capture_piles, piece) do
    case piece.color do
      :black -> %{capture_piles | black: [piece | capture_piles.black]}
      :white -> %{capture_piles | white: [piece | capture_piles.white]}
    end
  end

  # Game state checking functions
  def game_over?(board) do
    is_checkmate?(board, :white) || 
    is_checkmate?(board, :black) || 
    is_stalemate?(board, :white) || 
    is_stalemate?(board, :black) || 
    is_draw?(board)
  end

  def is_checkmate?(board, color) do
    king_in_check?(board, color) && has_no_legal_moves?(board, color)
  end

  def is_stalemate?(board, color) do
    !king_in_check?(board, color) && has_no_legal_moves?(board, color)
  end

  def is_draw?(board) do
    insufficient_material?(board) || 
    fifty_move_rule?(board) ||
    threefold_repetition?(board)
  end

  def king_in_check?(board, color) do
    king_pos = find_king(board, color)
    opposing_color = opposite_color(color)
    
    Enum.any?(get_pieces(board, opposing_color), fn {pos, piece} ->
      Chess.Piece.possible_moves(board, piece, pos)
      |> Enum.member?(king_pos)
    end)
  end

  defp find_king(board, color) do
    Enum.find_value(board.cells, fn {pos, piece} ->
      if piece && piece.type == :king && piece.color == color do
        pos
      end
    end)
  end

  defp has_no_legal_moves?(board, color) do
    get_pieces(board, color)
    |> Enum.all?(fn {from_pos, piece} ->
      Chess.Piece.possible_moves(board, piece, from_pos)
      |> Enum.all?(fn to_pos ->
        test_board = make_move(board, to_pos, from_pos)
        king_in_check?(test_board, color)
      end)
    end)
  end

  defp get_pieces(board, color) do
    Enum.filter(board.cells, fn {_pos, piece} ->
      piece && piece.color == color
    end)
  end

  defp insufficient_material?(board) do
    pieces = Enum.filter(board.cells, fn {_pos, piece} -> piece != nil end)
    
    case length(pieces) do
      2 -> true  # King vs King
      3 -> # King and Bishop vs King or King and Knight vs King
        has_only_minor_piece?(pieces)
      _ -> false
    end
  end

  defp has_only_minor_piece?(pieces) do
    pieces
    |> Enum.filter(fn {_pos, piece} -> 
      piece.type in [:bishop, :knight]
    end)
    |> length() == 1
  end

  defp fifty_move_rule?(board) do
    board.moves_since_capture >= 50
  end

  defp threefold_repetition?(board) do
    # Count occurrences of current position in history
    current_position_count = 
      Enum.count(board.move_history, fn position ->
        position == board.cells
      end)

    current_position_count >= 3
  end

  defp opposite_color(:white), do: :black
  defp opposite_color(:black), do: :white

  def standard() do
    %Chess.Board{
      width: 8, height: 8, cells: %{
        {0, 0} => %Chess.Piece{type: :rook, color: :black},
        {1, 0} => %Chess.Piece{type: :knight, color: :black},
        {2, 0} => %Chess.Piece{type: :bishop, color: :black},
        {3, 0} => %Chess.Piece{type: :queen, color: :black},
        {4, 0} => %Chess.Piece{type: :king, color: :black},
        {5, 0} => %Chess.Piece{type: :bishop, color: :black},
        {6, 0} => %Chess.Piece{type: :knight, color: :black},
        {7, 0} => %Chess.Piece{type: :rook, color: :black},
        {0, 1} => %Chess.Piece{type: :pawn, color: :black},
        {1, 1} => %Chess.Piece{type: :pawn, color: :black},
        {2, 1} => %Chess.Piece{type: :pawn, color: :black},
        {3, 1} => %Chess.Piece{type: :pawn, color: :black},
        {4, 1} => %Chess.Piece{type: :pawn, color: :black},
        {5, 1} => %Chess.Piece{type: :pawn, color: :black},
        {6, 1} => %Chess.Piece{type: :pawn, color: :black},
        {7, 1} => %Chess.Piece{type: :pawn, color: :black},

        {0, 2} => nil, {1, 2} => nil, {2, 2} => nil, {3, 2} => nil, {4, 2} => nil,
        {5, 2} => nil, {6, 2} => nil, {7, 2} => nil,

        {0, 3} => nil, {1, 3} => nil, {2, 3} => nil, {3, 3} => nil, {4, 3} => nil,
        {5, 3} => nil, {6, 3} => nil, {7, 3} => nil,

        {0, 4} => nil, {1, 4} => nil, {2, 4} => nil, {3, 4} => nil, {4, 4} => nil,
        {5, 4} => nil, {6, 4} => nil, {7, 4} => nil,

        {0, 5} => nil, {1, 5} => nil, {2, 5} => nil, {3, 5} => nil, {4, 5} => nil,
        {5, 5} => nil, {6, 5} => nil, {7, 5} => nil,

        {0, 6} => %Chess.Piece{type: :pawn, color: :white},
        {1, 6} => %Chess.Piece{type: :pawn, color: :white},
        {2, 6} => %Chess.Piece{type: :pawn, color: :white},
        {3, 6} => %Chess.Piece{type: :pawn, color: :white},
        {4, 6} => %Chess.Piece{type: :pawn, color: :white},
        {5, 6} => %Chess.Piece{type: :pawn, color: :white},
        {6, 6} => %Chess.Piece{type: :pawn, color: :white},
        {7, 6} => %Chess.Piece{type: :pawn, color: :white},
        {0, 7} => %Chess.Piece{type: :rook, color: :white},
        {1, 7} => %Chess.Piece{type: :knight, color: :white},
        {2, 7} => %Chess.Piece{type: :bishop, color: :white},
        {3, 7} => %Chess.Piece{type: :queen, color: :white},
        {4, 7} => %Chess.Piece{type: :king, color: :white},
        {5, 7} => %Chess.Piece{type: :bishop, color: :white},
        {6, 7} => %Chess.Piece{type: :knight, color: :white},
        {7, 7} => %Chess.Piece{type: :rook, color: :white},
      },
      capture_piles: %{black: [], white: []},
      move_history: [],
      moves_since_capture: 0
    }
  end

  def testboard() do
    %Chess.Board{
      width: 8, height: 8, cells: %{
        {0, 0} => %Chess.Piece{type: :rook, color: :black},
        {1, 0} => nil,
        {2, 0} => %Chess.Piece{type: :bishop, color: :black},
        {3, 0} => nil,
        {4, 0} => %Chess.Piece{type: :rook, color: :black},
        {5, 0} => nil,
        {6, 0} => %Chess.Piece{type: :king, color: :color},
        {7, 0} => nil,

        {0, 1} => %Chess.Piece{type: :pawn, color: :black},
        {1, 1} => %Chess.Piece{type: :pawn, color: :black},
        {2, 1} => nil,
        {3, 1} => nil,
        {4, 1} => %Chess.Piece{type: :queen, color: :black},
        {5, 1} => %Chess.Piece{type: :pawn, color: :black},
        {6, 1} => %Chess.Piece{type: :pawn, color: :black},
        {7, 1} => %Chess.Piece{type: :pawn, color: :black},

        {0, 2} => nil,
        {1, 2} => nil,
        {2, 2} => %Chess.Piece{type: :knight, color: :black},
        {3, 2} => %Chess.Piece{type: :pawn, color: :black},
        {4, 2} => nil,
        {5, 2} => %Chess.Piece{type: :knight, color: :pawn},
        {6, 2} => nil,
        {7, 2} => nil,

        {0, 3} => nil,
        {1, 3} => nil,
        {2, 3} => %Chess.Piece{type: :pawn, color: :black},
        {3, 3} => nil,
        {4, 3} => nil,
        {5, 3} => nil,
        {6, 3} => nil,
        {7, 3} => nil,

        {0, 4} => nil,
        {1, 4} => nil,
        {2, 4} => %Chess.Piece{type: :pawn, color: :white},
        {3, 4} => %Chess.Piece{type: :pawn, color: :white},
        {4, 4} => nil,
        {5, 4} => nil,
        {6, 4} => nil,
        {7, 4} => nil
      },
      capture_piles: %{black: [], white: []},
      move_history: [],
      moves_since_capture: 0
    }
  end
end
