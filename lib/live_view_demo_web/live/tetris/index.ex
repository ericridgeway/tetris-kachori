defmodule LiveViewDemoWeb.Tetris.Index do
  use Phoenix.LiveView
  alias LiveViewDemo.Tetris.{Tile, Game, Shape}

  def mount(_session, socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, 1000)
    {:ok, initial_state(socket)}
  end

  defp initial_state(socket) do
    game = Game.new()

    assign(socket,
      name: random_word(),
      game: game,
      game_over: game.game_over,
      # board: game.board,
      player_name: "somebody",
      new_game: true,
      speed: 300
    )
  end

  defp restart_game(socket, game_mode) do
    game = Game.new(game_mode)

    assign(socket,
      name: random_word(),
      game: game,
      game_over: game.game_over,
      # board: game.board,
    )
  end

  def render(%{new_game: true} = assigns) do
    # Phoenix.LiveView.live_render("tetris_game.html")
    LiveViewDemoWeb.TetrisView.render("tetris-welcome.html", assigns)
  end

  # def render(%{tetris: true} = assigns) do
  def render(%{game_over: true, game: game} = assigns) do
    ~L"""
    <div class="tetris-container">

    <div>

    <h1 style="color: red">
    Game Over !!!
    Your score was <%= game.score %>
    </h1>
    <br/>


    <div class="tetris options">
    <button phx-click="tetris-new-game" value="classic">New Classic Game</button>
    <button phx-click="tetris-new-game" value="evil">New Evil Game</button>
    </div>

    </div>

    </div>
    """

  end
  def render(%{game_over: false} = assigns) do
    LiveViewDemoWeb.TetrisView.render("tetris-game.html", assigns)
  end

  def render(assigns) do
    ~L"""

    <div>
    <button phx-click="tetris">Tetris toggle</button>
    </div>

    <br/>
    <div> word: <%= @name %> </div>
    <button phx-click="increment">increment counter</button>

    <button phx-click="counter" phx-value="incr">+</button>
    <button phx-click="counter" phx-value="decr">-</button>


    <pre phx-keyup="counter_grow" phx-target="window">
    Press a to increment by 5, b to increment by 3
    </pre>


    number <%#= @offset_y %>
    <div class="cards-container">

    <div class="column cards-column">
    <div class="card" draggable="true"> A </div>
    <div class="card" draggable="true"> B </div>
    <div class="card" draggable="true"> C </div>
    <div class="card" draggable="true"> J </div>
    <div class="card" draggable="true"> K </div>
    </div>

    <div class="column cards-column">
    <div class="card" draggable="true"> D </div>
    <div class="card" draggable="true"> E </div>
    <div class="card" draggable="true"> F </div>
    </div>

    <div class="column cards-column">
    <div class="card" draggable="true"> G </div>
    <div class="card" draggable="true"> H </div>
    <div class="card" draggable="true"> I </div>
    <div class="card" draggable="true"> L </div>
    </div>

    </div>
    """
  end

  def handle_event("game_submit", %{
        "player-name" => player_name,
        "game-mode" => game_mode} = form, socket) do
    mode = String.to_atom(game_mode)
    game = Game.new(mode)


    {:noreply,
     assign(socket,
       player_name: player_name,
       board: game.board,
       game: game,
       game_over: game.game_over,
       speed: game.speed,
       new_game: false
     )
    }
  end

  def handle_info(:click, %{counter: count} = socket) do
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, socket.assigns.speed)

     move_down(socket)
  end

  # def handle_event("move",  %{"code" => "ArrowUp"}, socket) do
  # def handle_event("tetris-new-game", value, socket) do
  def handle_event("tetris-new-game", %{ "value" => "classic"}, socket) do
    {:noreply, restart_game(socket, :regular)}
  end

  def handle_event("tetris-new-game", %{"value" => "evil"}, socket) do
    {:noreply, restart_game(socket, :evil)}
  end

  def handle_event("tetris", "rotate", socket) do
    # console.log("rotate...")
    {:noreply, assign(socket, shape: Shape.rotate(socket.assigns.game.active_shape))}
  end

  def handle_event("tetris", _path, socket) do
    {:noreply, assign(socket, tetris: !socket.assigns.tetris)}
  end

  def handle_event("counter", "incr", socket) do
    {:noreply, inc(socket, 1)}
  end

  def handle_event("counter", "decr", socket) do
    {:noreply, inc(socket, -1)}
  end


  def handle_event("joystick-move", %{"dir" => direction}, socket) do
    # add strong validation, direction has to be valid
    # IO.puts inspect(direction)

    game = case String.to_atom(direction) do
             :left ->
               Game.move_object(socket.assigns.game, :left)
             :right ->
               Game.move_object(socket.assigns.game, :right)
             :up ->
               Game.rotate_shape(socket.assigns.game)
             :down ->
               Game.move_object(socket.assigns.game, :down)
           end

    {:noreply, assign(socket, game: game)}
  end

  def handle_event("move", %{"code" => "ArrowLeft"}, socket) do
    {:noreply,
     assign(socket, game: Game.move_object(socket.assigns.game, :left) )
    }
  end

  def handle_event("move",  %{"code" => "ArrowRight"}, socket) do
    {:noreply,
     assign(socket, game: Game.move_object(socket.assigns.game, :right) )
    }
  end

  def handle_event("move",  %{"code" => "ArrowUp"}, socket) do
    # {:noreply, assign(socket, shape: Shape.rotate(socket.assigns.game.active_shape))}
    {:noreply, assign(socket, game: Game.rotate_shape(socket.assigns.game))}
  end

  def handle_event("move", %{"code" =>  "ArrowDown"}, socket) do
    move_down(socket)
  end

  def handle_event("counter_grow", "a", socket) do
    {:noreply, inc(socket, 5)}
  end

  def handle_event("counter_grow", "b", socket) do
    {:noreply, inc(socket, 3)}
  end

  def handle_event(_, _key, socket) do
    {:noreply, socket
    }
  end

  defp inc(socket, offset) do
    assign(socket, counter: (socket.assigns.counter + offset))
  end

  defp change_axis(socket, offset) do
    assign(socket, x: (socket.assigns.x + offset))
  end

  defp move_down(socket, offset \\ 1) do
    game_state = Game.move_object(socket.assigns.game, :down)
    {
      :noreply,
      assign(socket,
        game: game_state,
        game_over: game_state.game_over
      )
    }
  end

  def handle_event("increment", _path, socket) do
    {:noreply, assign(socket, counter: (socket.assigns.counter + 1))}
  end

  defp random_word do
    ~w(one two three four five six seven eight nine zero)
    |> Enum.random
  end

end
