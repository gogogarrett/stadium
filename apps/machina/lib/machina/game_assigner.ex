defmodule Machina.GameAssigner do
  use GenServer

  def start_link(scope) do
    GenServer.start_link(__MODULE__, scope, [name: context(scope)])
  end

  def name(pid) do
    GenServer.call(pid, :name)
  end

  def fetch_state(pid) do
    GenServer.call(pid, :fetch_state)
  end

  def add_player(pid, player_id) do
    GenServer.call(pid, {:add_player, player_id})
  end

  def init(context) do
    :timer.send_interval(2_000, :assign_games)

    {:ok, %{
      context: context,
      waiting_players: [],
      had_players: false
    }}
  end

  def handle_info(:assign_games, state) do
    IO.inspect(state)

    with {:ok, new_players, game} <- create_game(state)
    do
      StadiumWeb.Endpoint.broadcast("lobby:game_assigner", "game_offer", game)

      {:noreply, Map.update!(state, :waiting_players, fn (_x) -> new_players end)}
    else
      {:error, :no_players} ->
        {:stop, :normal, state}
      _ ->
        {:noreply, state}
    end
  end

  defp create_game(%{waiting_players: waiting_players} = state)
    when length(waiting_players) >= 4 do

    new_players = Enum.drop(waiting_players, 4)

    {:ok, new_players, %{
        game_id: 1,
        players: waiting_players,
        questions: [
          "how are you",
          "what's up",
          "where am i"
        ]
      }
    }
  end

  defp create_game(%{waiting_players: waiting_players, had_players: true})
    when length(waiting_players) == 0 do
    {:error, :no_players}
  end

  defp create_game(state) do
    {:error, :not_started}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.context, state}
  end

  def handle_call(:fetch_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add_player, player_id}, _from, state) do
    new_state =
      %{state |
        waiting_players: Enum.uniq(state.waiting_players ++ [player_id]),
        had_players: true
      }

    {:reply, new_state, new_state}
  end

  defp context(scope), do: :"context:#{scope}"
end
