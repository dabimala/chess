defmodule ChessWeb.GameLive.Show do
  use ChessWeb, :live_view
  alias Chess.GameState
  alias ChessWeb.Live.GameLive.GameLogic
  alias Chess.Game.GameManager

  @pieces %{
    "wP" => %{symbol: "\u2659", class: "white-piece", description: "Pawn: Moves forward one square, attacks diagonally."},
    "wR" => %{symbol: "\u2656", class: "white-piece", description: "Rook: Moves horizontally or vertically any number of squares."},
    "wN" => %{symbol: "\u2658", class: "white-piece", description: "Knight: Moves in an 'L' shape, can jump over pieces."},
    "wB" => %{symbol: "\u2657", class: "white-piece", description: "Bishop: Moves diagonally any number of squares."},
    "wQ" => %{symbol: "\u2655", class: "white-piece", description: "Queen: Moves in any direction any number of squares."},
    "wK" => %{symbol: "\u2654", class: "white-piece", description: "King: Moves one square in any direction. Checkmate to win!"},
    "bP" => %{symbol: "\u265F", class: "black-piece", description: "Pawn: Moves forward one square, attacks diagonally."},
    "bR" => %{symbol: "\u265C", class: "black-piece", description: "Rook: Moves horizontally or vertically any number of squares."},
    "bN" => %{symbol: "\u265E", class: "black-piece", description: "Knight: Moves in an 'L' shape, can jump over pieces."},
    "bB" => %{symbol: "\u265D", class: "black-piece", description: "Bishop: Moves diagonally any number of squares."},
    "bQ" => %{symbol: "\u265B", class: "black-piece", description: "Queen: Moves in any direction any number of squares."},
    "bK" => %{symbol: "\u265A", class: "black-piece", description: "King: Moves one square in any direction. Checkmate to win!"}
  }

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      case params do
        %{"id" => game_id} ->
          case GameManager.get_game(game_id) do
            nil ->
              {:ok, game_id} = GameManager.create_game()
              {:ok, 
                socket
                |> assign(:game_id, game_id)
                |> assign(:game, GameState.new_game())
                |> assign(:selected_square, nil)
                |> assign(:valid_moves, [])
                |> assign(:player_color, nil)
                |> assign(:pieces, @pieces)}

            game_state ->
              {:ok, 
                socket
                |> assign(:game_id, game_id)
                |> assign(:game, game_state)
                |> assign(:selected_square, nil)
                |> assign(:valid_moves, [])
                |> assign(:player_color, nil)
                |> assign(:pieces, @pieces)}
          end

        _ ->
          game_id = generate_game_id()
          {:ok, 
            socket
            |> assign(:game_id, game_id)
            |> assign(:game, GameState.new_game())
            |> assign(:selected_square, nil)
            |> assign(:valid_moves, [])
            |> assign(:player_color, nil)
            |> assign(:pieces, @pieces)}
      end
    else
      {:ok, 
        socket
        |> assign(:game_id, nil)
        |> assign(:game, GameState.new_game())
        |> assign(:selected_square, nil)
        |> assign(:valid_moves, [])
        |> assign(:player_color, nil)
        |> assign(:pieces, @pieces)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <%= if @game_id do %>
        <div class="text-center mb-4">
          <div>Game ID: <%= @game_id %></div>
          <%= if @player_color do %>
            <div>You are playing as: <%= @player_color %></div>
          <% else %>
            <div>Waiting for opponent...</div>
          <% end %>
        </div>
      <% end %>
      <div class="chess-board" phx-hook="Game" id="game-board" data-game-id={@game_id}>
        <%= for row <- 0..7 do %>
          <div class="row">
            <%= for col <- 0..7 do %>
              <% 
                piece = Map.get(@game.board, {row, col})
                is_selected = @selected_square == {row, col}
                is_valid_move = {row, col} in @valid_moves
                square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
                piece_data = if piece, do: @pieces[piece]
              %>
              <div class={"square #{square_color} #{if is_selected, do: "selected"} #{if is_valid_move, do: "valid-move"}"}
                  phx-click="select_square"
                  phx-value-row={row}
                  phx-value-col={col}>
                <%= if piece_data do %>
                  <span class={"chess-piece #{piece_data.class}"}>
                    <%= piece_data.symbol %>
                  </span>
                  <div class="tooltip">
                    <%= piece_data.description %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
      <div class="text-center mt-4 text-xl font-bold">
        Current turn: <%= String.capitalize(to_string(@game.turn)) %>
      </div>
    </div>
    """
  end


  @impl true
  def handle_event("select_square", %{"row" => row, "col" => col}, socket) do
    IO.puts("Square clicked!")
    position = {String.to_integer(row), String.to_integer(col)}
    game = socket.assigns.game

    IO.inspect(position, label: "Current position")
    
    cond do
      # If we have a piece selected and this is a target square
      socket.assigns.selected_square != nil ->
        from = socket.assigns.selected_square
        IO.inspect(from, label: "From position")
        # Try to make the move
        new_board = GameLogic.make_move(game.board, from, position)
        
        # If the board changed, the move was valid
        if new_board != game.board do
          new_game = %{game | 
            board: new_board,
            turn: if(game.turn == :white, do: :black, else: :white)
          }
          IO.puts("Valid move made")
          IO.inspect(new_game.board, label: "New board state")

            from_list = Tuple.to_list(from)
            to_list = Tuple.to_list(position)
             
           IO.inspect(from_list, label: "From list")
           IO.inspect(to_list, label: "To list")       
 
        
           {:noreply, assign(socket, 
            game: new_game,
            selected_square: nil,
            valid_moves: []
          )}
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
        case Map.get(game.board, position) do
          nil -> 
            # Clicked empty square - clear selection
            IO.puts("Clicked empty square - clearing selection")
            {:noreply, assign(socket,
              selected_square: nil,
              valid_moves: []
            )}
          
          piece ->
            # Only allow selecting pieces of current player's color
            if GameLogic.piece_color(piece) == game.turn do
              IO.puts("Selected piece: #{piece}")
              valid_moves = GameLogic.valid_moves(game.board, position)
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
    
    new_board = GameLogic.make_move(socket.assigns.game.board, from_pos, to_pos)
    new_game = %{socket.assigns.game | 
      board: new_board,
      turn: if(socket.assigns.game.turn == :white, do: :black, else: :white)
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

  defp generate_game_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64()
  end
end
