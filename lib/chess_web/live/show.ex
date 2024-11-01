defmodule ChessWeb.Live.Show do
  use ChessWeb, :live_view

#  defp generate_game_id do
#    :crypto.strong_rand_bytes(8) |> Base.url_encode64()
#  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    IO.inspect id, label: "mount() id"

    if (connected?(socket)) do
      # TODO: fetch game from server with id
      IO.puts "Connected"
      {:ok, socket |> assign(:game, id)
                   |> assign(:board, Chess.Board.standard())}
    else
      IO.puts "Not connected"
      {:ok, socket |> assign(:game, id)
                   |> assign(:board, Chess.Board.standard())}
    end
  end

  @impl true
  def mount(_, _session, socket) do
    {:error, socket}
  end

  defp random_movable_piece(board = %Chess.Board{cells: cells}) do
    loc = Map.keys(cells) |> Enum.random()

    if cells[loc] != nil do
      moves = Chess.Piece.possible_moves(board, cells[loc], loc)
      if length(moves) > 1 do
	{loc, moves}
      else
	random_movable_piece(board)
      end
    else
      random_movable_piece(board)
    end
  end

  @impl true
  def render(assigns) do
    board = assigns[:board]
#    IO.inspect board, label: "show() board"
#    IO.inspect random_movable_piece(board), label: "piece and moves"

    {loc, moves} = random_movable_piece(board)
    move = Enum.random(moves)
#    IO.inspect loc, label: "from"
#    IO.inspect move, label: "to"
#    IO.inspect board.cells[loc], label: "a"
#    IO.inspect board, label: "before", limit: :infinity
    board = Chess.Board.make_move(board, move, loc)
#    IO.inspect board, label: "after", limit: :infinity

    assigns = assign(assigns, :board, board)

~H"""
<div class="board">
 <%= for x <- 0..7 do %>
  <div class="row">
   <%= for y <- 0..7 do %>
   <button class="square" phx-click="click_square" phx-value-row={y}>
    <%=
     piece = assigns[:board].cells[{x, y}]
     unless piece == nil do
       Chess.Piece.glyphs()[piece.color][piece.type]
     end
     %>
    </button>
   <% end %>
  </div>
 <% end %>
</div>
"""
  end

  @impl true
  def handle_event(_, _, _socket) do
    IO.puts "!! handle_event() called !!"
  end
end
