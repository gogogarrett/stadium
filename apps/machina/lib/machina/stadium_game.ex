defmodule Machina.StadiumGame do
  use GenServer

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, [name: game_id(game_id)])
  end

  def name(pid) do
    GenServer.call(pid, :name)
  end

  def fetch_state(pid) do
    GenServer.call(pid, :fetch_state)
  end

  def update_state(pid, user_id, score) do
    GenServer.call(pid, {:update_state, user_id, score})
  end

  def add_players(pid, players) do
    GenServer.call(pid, {:add_players, players})
  end

  def init(game_id) do
    {:ok, %{
      game_id: game_id,
      game_state: %{players: []}
    }, 5_000}
  end

  def handle_info(:timeout, state) do
    IO.inspect("handle_info: timeout")

    StadiumWeb.Endpoint.broadcast("game:#{state.game_id}", "game_end", state)

    {:stop, :normal, state}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.game_id, state, 5_000}
  end

  def handle_call(:fetch_state, _from, state) do
    {:reply, state, state, 5_000}
  end

  def handle_call({:add_players, players}, _from, state) do
    player_maps =
      Enum.map(players, fn(player) ->
        %{id: player.player_id, score: 0}
      end)

    new_state = put_in(state, [:game_state, :players], Enum.uniq(player_maps))

    {:reply, new_state, new_state, 5_000}
  end

  def handle_call({:update_state, user_id, score}, _from, %{game_state: game_state} = state) do
    updated_players = update_players(game_state.players, user_id, score)
    new_state = put_in(state, [:game_state, :players], updated_players)

    {:reply, new_state, new_state, 5_000}
  end

  def update_players(players, user_id, score) do
    players
    |> Enum.map(fn (player) -> update_player(player, user_id, score) end)
  end

  defp update_player(player = %{id: id}, id, score) do
    %{player | score: player.score + score}
  end
  defp update_player(player, _, _), do: player

  defp game_id(game_id), do: :"game_#{game_id}"
end
