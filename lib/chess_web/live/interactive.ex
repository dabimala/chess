defmodule ChessWeb.Live.Interactive do
  use ChessWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if (connected?(socket)) do
      # TODO: fetch game from server with id
      IO.puts "Connected with ID"
      {:ok, socket |> assign(:game, id)
                   |> assign(:board, Chess.Board.testboard())
                   |> assign(:turn, :white)
                   |> assign(:selected_square, nil)
                   |> assign(:valid_moves, [])
                   |> assign(:player_color, nil)}
    else
      IO.puts "Not connected with ID"
      {:ok, socket |> assign(:game, id)
                   |> assign(:board, Chess.Board.testboard())
                   |> assign(:turn, :white)
                   |> assign(:selected_square, nil)
                   |> assign(:valid_moves, [])
                   |> assign(:player_color, nil)}
    end
  end

  @impl true
  def mount(_, _session, socket) do
    if (connected?(socket)) do
      # TODO: fetch game from server with id
      IO.puts "Connected no ID"
      {:ok, socket |> assign(:game, nil)
                   |> assign(:board, Chess.Board.standard())
                   |> assign(:turn, :white)
                   |> assign(:selected_square, nil)
                   |> assign(:valid_moves, [])
                   |> assign(:player_color, nil)}
    else
      IO.puts "Not connected no ID"
      {:ok, socket |> assign(:game, nil)
                   |> assign(:board, Chess.Board.standard())
                   |> assign(:turn, :white)
                   |> assign(:selected_square, nil)
                   |> assign(:valid_moves, [])
                   |> assign(:player_color, nil)}
    end
  end

  @impl true
  def render(assigns) do
    if assigns[:board]  == nil do
~H"""
<center> <h2> Connecting to chess game... </h2> </center>
"""
    else
~H"""
<div class="container mx-auto px-4 py-8">
  <%= if @game do %>
    <div class="text-center mb-4">
      <div>Game ID: <%= @game %></div>
      <%= if @player_color do %>
        <div>You are playing as: <%= @player_color %></div>
      <% else %>
        <div>Waiting for opponent...</div>
      <% end %>
    </div>
  <% end %>
  <div class="chess-board" phx-hook="Game" id="game-board" data-game-id={@game}>
    <%= for row <- 0..7 do %>
      <div class="row">
        <%= for col <- 0..7 do %>
          <% 
            piece = Map.get(@board.cells, {row, col})
            is_selected = @selected_square == {row, col}
            is_valid_move = {row, col} in @valid_moves
            square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
            piece_data = if piece, do: Chess.Piece.glyphs()[piece.color][piece.type]
          %>
          <div class={"square #{square_color} #{if is_selected, do: "selected"} #{if is_valid_move, do: "valid-move"}"}
               phx-click="select_square"
               phx-value-row={row}
               phx-value-col={col}>
            <%= if piece_data do %>
              <span class={"chess-piece #{piece.type}"}>
                <%= piece_data %>
              </span>
            <% end %>
          </div>
        <% end %>
      </div>
    <% end %>
  </div>
  <div class="text-center mt-4 text-xl font-bold">
    Current turn: <%= String.capitalize(to_string(@turn)) %>
  </div>
</div>
"""
    end
  end

  @impl true
  def handle_event("select_square", %{"row" => row, "col" => col}, socket) do
    IO.puts("Square clicked!")
    position = {String.to_integer(row), String.to_integer(col)}

    IO.inspect(position, label: "Current position")
    
    cond do
      # If we have a piece selected and this is a target square
      socket.assigns.selected_square != nil ->
        from = socket.assigns.selected_square
        IO.inspect(from, label: "From position")
        # Try to make the move
    IO.inspect from, label: "from"
    IO.inspect position, label: "position"
        
        # If the board changed, the move was valid
	if position in Chess.Piece.possible_moves(socket.assigns[:board], socket.assigns[:board].cells[from], from) do
#        if new_board != socket.assigns[:board].cells do
	  new_board = Chess.Board.make_move(socket.assigns[:board], position, from)
          IO.puts("Valid move made")
          IO.inspect(new_board, label: "New board state")

            from_list = Tuple.to_list(from)
            to_list = Tuple.to_list(position)
             
           IO.inspect(from_list, label: "From list")
           IO.inspect(to_list, label: "To list")       
        
	   {:noreply, socket |> assign(:game, socket.assigns[:game])
                        |> assign(:board, new_board)
                        |> assign(:turn, if(socket.assigns[:turn] == :white, do: :black, else: :white))
                        |> assign(:selected_square, nil)
                        |> assign(:valid_moves, [])
                        |> assign(:player_color, nil)}
        else
          # Invalid move - just clear selection
          IO.puts("Invalid move - clearing selection")
          {:noreply, assign(socket,
            selected_square: nil,
            valid_moves: []
          )}
        end

      # If we're selecting a piece
      true ->
        case Map.get(socket.assigns[:board].cells, position) do
          nil -> 
            # Clicked empty square - clear selection
            IO.puts("Clicked empty square - clearing selection")
            {:noreply, assign(socket,
              selected_square: nil,
              valid_moves: []
            )}
          
          piece ->
            # Only allow selecting pieces of current player's color
	    if piece.color == socket.assigns[:turn] do
              IO.puts("Selected piece: #{piece.color} #{piece.type}")
              valid_moves = Chess.Piece.possible_moves(socket.assigns[:board], piece, position)
              IO.inspect(valid_moves, label: "Valid moves")
              {:noreply, assign(socket,
                  selected_square: position,
                  valid_moves: valid_moves
              )}
            else
              IO.puts("Selected opponent's piece - ignoring")
              {:noreply, socket}
            end
        end
    end
  end

  @impl true
  def handle_event("remote_move", %{"from" => from, "to" => to}, socket) do
    # Convert string positions to tuples
    from_pos = List.to_tuple(from)
    to_pos = List.to_tuple(to)    
    
    new_board = Chess.Board.make_move(socket.assigns[:board].cells, to_pos, from_pos)
    new_game = %{socket.assigns.game | 
      board: new_board,
      turn: if(socket.assigns.turn == :white, do: :black, else: :white)
    }
    
    {:noreply, assign(socket, game: new_game)}
  end

   @impl true
  def handle_event("push_move", %{"from" => from, "to" => to}, socket) do
    # This will be called when we want to send a move to other players
    {:noreply, push_event(socket, "make_move", %{
      from: from,
      to: to,
      player: socket.assigns.player_color
    })}
  end
end
