defmodule Machina.GameAssigner.GameFactory do
  @doc """
  Build a game with any number of players - and droids will fill in the rest via client
  """
  def build_with_droids(%{waiting_players: waiting_players} = state) do
    game_ref = game_id

    player_size = Enum.count(waiting_players)
    with new_players <- Enum.drop(waiting_players, player_size),
         stadium_game_pid when is_pid(stadium_game_pid) <- find_or_create_game(game_ref),
         {:ok, _} <- add_players_to_game(stadium_game_pid, waiting_players) do
      {:ok, new_players, %{
        game_id: game_ref,
        players: waiting_players,
        questions: ["how are you", "what's up", "where am i"]
      }}
    else
      _ ->
        IO.inspect("broken")
    end
  end

  @doc """
  Build a game with >= 4 players
  """
  def build(%{waiting_players: waiting_players} = state)
    when length(waiting_players) >= 4 do

    game_ref = game_id

    with new_players <- Enum.drop(waiting_players, 4),
         stadium_game_pid when is_pid(stadium_game_pid) <- find_or_create_game(game_ref),
         {:ok, _} <- add_players_to_game(stadium_game_pid, waiting_players) do
      {:ok, new_players, %{
        game_id: game_ref,
        players: waiting_players,
        questions: ["how are you", "what's up", "where am i"]
      }}
    else
      _ ->
        IO.inspect("broken")
    end
  end

  def build(%{waiting_players: waiting_players, had_players: true})
    when length(waiting_players) == 0 do
    {:error, :no_players}
  end

  def build(state) do
    {:error, :waiting}
  end

  defp find_or_create_game(game_name) do
    case Machina.StadiumGameSup.find_game(game_name) do
      game when is_pid(game) -> game
      _ ->
        {:ok, game} = Machina.StadiumGameSup.add_game(game_name)
        game
    end
  end

  defp add_players_to_game(game_pid, waiting_players) do
    {:ok, Machina.StadiumGame.add_players(game_pid, waiting_players)}
  end

  def game_id, do: Ecto.UUID.generate
end
