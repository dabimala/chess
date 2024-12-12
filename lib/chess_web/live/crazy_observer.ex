# lib/chess_web/live/crazy_observer.ex
defmodule ChessWeb.Live.CrazyObserver do
  use ChessWeb, :live_view
  require Logger

  @pubsub_topic_prefix "crazy_game:"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Logger.info("Mounting Crazy Chess Observer for game: #{id}")
    
    if connected?(socket) do
      Chess.PubSub.subscribe("#{@pubsub_topic_prefix}#{id}")
      
      game_state = Chess.GameState.get_game(id)
      Logger.info("Observer found game state: #{inspect(game_state)}")
      
      case game_state do
        nil -> 
          {:ok, socket |> redirect(to: "/crazy")}
        game_state ->
          {:ok, socket |> assign(:game, id)
                      |> assign(:board, game_state.board)
                      |> assign(:turn, game_state.turn)
                      |> assign(:game_over, Map.get(game_state, :game_over, false))
                      |> assign(:game_result, Map.get(game_state, :game_result, nil))}
      end
    else
      {:ok, socket |> assign(:game, id)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="text-center mb-4">
        <div class="text-2xl font-bold">Observing Crazy Chess Game</div>
        <div class="text-lg mt-2">Game ID: <%= @game %></div>
        <div class="text-lg">Current turn: <%= String.capitalize(to_string(@turn)) %></div>
      </div>

      <div class="chess-board">
        <%= for row <- 0..7 do %>
          <div class="row">
            <%= for col <- 0..7 do %>
              <%
                piece = Map.get(@board.cells, {row, col})
                square_color = if rem(row + col, 2) == 0, do: "white", else: "black"
                piece_data = if piece, do: Chess.CrazyPiece.glyphs()[piece.color][piece.type]
              %>
              <div class={"square #{square_color}"}>
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

      <div class="mt-4 grid grid-cols-2 gap-4 max-w-2xl mx-auto">
        <div class="bg-white p-4 rounded shadow">
          <h3 class="font-bold mb-2">Magical Pieces:</h3>
          <div class="grid grid-cols-2 gap-2">
            <div>🐉 Dragon: Queen + Knight moves</div>
            <div>🧙‍♂️ Wizard: Teleport anywhere</div>
            <div>🥷 Ninja: Knight + adjacent moves</div>
            <div>🦅 Phoenix: Jumping diagonal moves</div>
          </div>
        </div>
        <div class="bg-white p-4 rounded shadow">
          <h3 class="font-bold mb-2">Special Rules:</h3>
          <ul class="text-sm">
            <li>Dragon can move like a queen or knight</li>
            <li>Wizard can teleport to any empty square</li>
            <li>Ninja combines knight and king movements</li>
            <li>Phoenix moves diagonally and can jump pieces</li>
          </ul>
        </div>
      </div>

      <%= if @game_over do %>
        <div class="text-center mt-4 text-xl font-bold text-red-600">
          <%= @game_result %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_info({:move_made, game_state}, socket) do
    {:noreply, socket
      |> assign(:board, game_state.board)
      |> assign(:turn, game_state.turn)
      |> assign(:game_over, game_state.game_over)
      |> assign(:game_result, game_state.game_result)}
  end
end
