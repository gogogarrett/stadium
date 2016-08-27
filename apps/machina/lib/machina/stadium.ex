defmodule Machina.Stadium do
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

  def init(game_id) do
    {:ok, %{
      game_id: game_id,
      game_state: %{
        players: [
          %{id: "1", score: 0},
          %{id: "2", score: 0},
          %{id: "3", score: 0},
          %{id: "4", score: 0},
        ]
      }
    }}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.game_id, state}
  end

  def handle_call(:fetch_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update_state, user_id, score}, _from, %{game_state: game_state} = state) do
    updated_players = update_players(game_state.players, user_id, score)
    new_state = put_in(state, [:game_state, :players], updated_players)

    {:reply, new_state, new_state}
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
