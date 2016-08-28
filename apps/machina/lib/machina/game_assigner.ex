defmodule Machina.GameAssigner do
  use GenServer

  alias Machina.GameAssigner.{Timeout, GameFactory}

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

    with {:ok, :waiting} <- Timeout.check(state.waiting_players),
         {:ok, new_players, game} <- GameFactory.build(state)
    do
      StadiumWeb.Endpoint.broadcast("lobby:game_assigner", "game_offer", game)

      {:noreply, Map.update!(state, :waiting_players, fn (_x) -> new_players end)}
    else
      {:error, :no_players} ->
        {:stop, :normal, state}
      {:error, :timeout_expired} ->
        new_players = case Enum.count(state.waiting_players) do
          count when count in [2, 3] ->
            {:ok, new_players, game} = GameFactory.build_with_droids(state)
            StadiumWeb.Endpoint.broadcast("lobby:game_assigner", "game_offer", game)
            new_players
          _ ->
            StadiumWeb.Endpoint.broadcast("lobby:game_assigner", "game_reject", %{})
            []
        end
        {:stop, :normal, Map.update!(state, :waiting_players, fn (_x) -> new_players end)}
      _ ->
        {:noreply, state}
    end
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
        waiting_players: Enum.uniq(state.waiting_players ++ [%{join_time: current_time, player_id: player_id}]),
        had_players: true
      }

    {:reply, new_state, new_state}
  end

  defp context(scope), do: :"context:#{scope}"

  def current_time, do: DateTime.utc_now() |> DateTime.to_unix()
end
