defmodule Machina.GameAssignerSup do
  use Supervisor
  alias Machina.GameAssigner

  def add_assigner(game_id) do
    Supervisor.start_child(__MODULE__, [game_id])
  end

  def find_assigner(game_id) do
    Enum.find games, fn(child) ->
      GameAssigner.name(child) == game_id
    end
  end

  defp games do
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
      worker(GameAssigner, [], restart: :temporary)
    ]
    |> supervise(strategy: :simple_one_for_one)
  end
end
