defmodule Machina.StadiumGameSup do
  use Supervisor
  alias Machina.Stadium

  def add_game(game_id) do
    Supervisor.start_child(__MODULE__, [game_id])
  end

  def delete_game(game_id) do
    Supervisor.terminate_child(__MODULE__, game_id)
  end

  def find_game(game_id) do
    Enum.find games, fn(child) ->
      Stadium.name(child) == game_id
    end
  end

  def games do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.map(fn({_, pid, _, _}) -> pid end)
  end

  ###
  # Supervisor API
  ###
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    [
      worker(Stadium, [])
    ]
    |> supervise(strategy: :simple_one_for_one)
  end
end
