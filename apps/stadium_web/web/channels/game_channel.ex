defmodule StadiumWeb.GameChannel do
  use StadiumWeb.Web, :channel

  def join("game:" <> game_id, _payload, socket) do
    game = find_or_create_game(game_id)

    socket =
      socket
      |> assign(:game_pid, game)


    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    game_state =
      socket.assigns.game_pid
      |> Machina.StadiumGame.fetch_state

    send_game_state(socket, game_state)

    {:noreply, socket}
  end

  def handle_in("submit_answer", payload, socket) do
    game_state =
      socket.assigns.game_pid
      |> Machina.StadiumGame.update_state(socket.assigns.user_id, payload)

    send_game_state(socket, game_state)

    {:noreply, socket}
  end

  defp send_game_state(socket, game_state) do
    broadcast(socket, "game_state_updated", game_state)
  end

  defp find_or_create_game(game_name) do
    case Machina.StadiumGameSup.find_game(game_name) do
      game when is_pid(game) -> game
      _ ->
        {:ok, game} = Machina.StadiumGameSup.add_game(game_name)
        game
    end
  end
end
