defmodule Chess.CrazyBoard do
  defstruct width: nil,
            height: nil,
            cells: %{} # {coordinate} => %Chess.CrazyPiece{}

  def make_move(board = %Chess.CrazyBoard{cells: cells}, to, from) do
    if to == from do
      board
    else
      piece = cells[from]
      updated_piece = %{piece | has_moved: true}
      %{board | cells: %{cells | to => updated_piece, from => nil}}
    end
  end

  def standard do
    %Chess.CrazyBoard{
      width: 8, height: 8, cells: %{
        # Black pieces back row (column 0)
        {0, 0} => Chess.CrazyPiece.new(:dragon, :black),
        {1, 0} => Chess.CrazyPiece.new(:ninja, :black),
        {2, 0} => Chess.CrazyPiece.new(:phoenix, :black),
        {3, 0} => Chess.CrazyPiece.new(:wizard, :black),
        {4, 0} => Chess.CrazyPiece.new(:king, :black),
        {5, 0} => Chess.CrazyPiece.new(:phoenix, :black),
        {6, 0} => Chess.CrazyPiece.new(:ninja, :black),
        {7, 0} => Chess.CrazyPiece.new(:dragon, :black),

        # Black pawns (column 1)
        {0, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {1, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {2, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {3, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {4, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {5, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {6, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {7, 1} => Chess.CrazyPiece.new(:pawn, :black),

        # Empty middle squares
        {0, 2} => nil, {1, 2} => nil, {2, 2} => nil, {3, 2} => nil,
        {4, 2} => nil, {5, 2} => nil, {6, 2} => nil, {7, 2} => nil,

        {0, 3} => nil, {1, 3} => nil, {2, 3} => nil, {3, 3} => nil,
        {4, 3} => nil, {5, 3} => nil, {6, 3} => nil, {7, 3} => nil,

        {0, 4} => nil, {1, 4} => nil, {2, 4} => nil, {3, 4} => nil,
        {4, 4} => nil, {5, 4} => nil, {6, 4} => nil, {7, 4} => nil,

        {0, 5} => nil, {1, 5} => nil, {2, 5} => nil, {3, 5} => nil,
        {4, 5} => nil, {5, 5} => nil, {6, 5} => nil, {7, 5} => nil,

        # White pawns (column 6)
        {0, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {1, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {2, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {3, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {4, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {5, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {6, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {7, 6} => Chess.CrazyPiece.new(:pawn, :white),

        # White pieces back row (column 7)
        {0, 7} => Chess.CrazyPiece.new(:dragon, :white),
        {1, 7} => Chess.CrazyPiece.new(:ninja, :white),
        {2, 7} => Chess.CrazyPiece.new(:phoenix, :white),
        {3, 7} => Chess.CrazyPiece.new(:wizard, :white),
        {4, 7} => Chess.CrazyPiece.new(:king, :white),
        {5, 7} => Chess.CrazyPiece.new(:phoenix, :white),
        {6, 7} => Chess.CrazyPiece.new(:ninja, :white),
        {7, 7} => Chess.CrazyPiece.new(:dragon, :white),
      }
    }
  end

  def testboard do
    %Chess.CrazyBoard{
      width: 8, height: 8, cells: %{
        # Test layout with fewer pieces for debugging
        {0, 0} => Chess.CrazyPiece.new(:dragon, :black),
        {4, 0} => Chess.CrazyPiece.new(:king, :black),
        {7, 0} => Chess.CrazyPiece.new(:wizard, :black),
        
        {0, 1} => Chess.CrazyPiece.new(:pawn, :black),
        {4, 1} => Chess.CrazyPiece.new(:phoenix, :black),
        {7, 1} => Chess.CrazyPiece.new(:ninja, :black),

        {3, 3} => Chess.CrazyPiece.new(:dragon, :white),
        {4, 4} => Chess.CrazyPiece.new(:wizard, :white),
        
        {0, 6} => Chess.CrazyPiece.new(:pawn, :white),
        {4, 6} => Chess.CrazyPiece.new(:phoenix, :white),
        {7, 6} => Chess.CrazyPiece.new(:ninja, :white),
        
        {0, 7} => Chess.CrazyPiece.new(:dragon, :white),
        {4, 7} => Chess.CrazyPiece.new(:king, :white),
        {7, 7} => Chess.CrazyPiece.new(:wizard, :white),

        # Fill remaining squares with nil
        {1, 0} => nil, {2, 0} => nil, {3, 0} => nil, {5, 0} => nil, {6, 0} => nil,
        {1, 1} => nil, {2, 1} => nil, {3, 1} => nil, {5, 1} => nil, {6, 1} => nil,
        {0, 2} => nil, {1, 2} => nil, {2, 2} => nil, {3, 2} => nil, {4, 2} => nil, {5, 2} => nil, {6, 2} => nil, {7, 2} => nil,
        {0, 3} => nil, {1, 3} => nil, {2, 3} => nil, {4, 3} => nil, {5, 3} => nil, {6, 3} => nil, {7, 3} => nil,
        {0, 4} => nil, {1, 4} => nil, {2, 4} => nil, {3, 4} => nil, {5, 4} => nil, {6, 4} => nil, {7, 4} => nil,
        {0, 5} => nil, {1, 5} => nil, {2, 5} => nil, {3, 5} => nil, {4, 5} => nil, {5, 5} => nil, {6, 5} => nil, {7, 5} => nil,
        {1, 6} => nil, {2, 6} => nil, {3, 6} => nil, {5, 6} => nil, {6, 6} => nil,
        {1, 7} => nil, {2, 7} => nil, {3, 7} => nil, {5, 7} => nil, {6, 7} => nil
      }
    }
  end
end
