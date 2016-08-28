defmodule StadiumWeb.LobbyChannel do
  use StadiumWeb.Web, :channel

  def join("lobby:game_assigner", payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("request_game", %{"user_id" => user_id, "scope" => scope}, socket) do
    assigner = find_or_create_game_assigner(scope)

    socket =
      socket
      |> assign(:assigner_pid, assigner)

    Machina.GameAssigner.add_player(assigner, user_id)

    {:reply, {:ok, %{}}, socket}
  end

  defp find_or_create_game_assigner(scope) do
    case Machina.GameAssignerSup.find_assigner(scope) do
      assigner when is_pid(assigner) -> assigner
      _ ->
        {:ok, assigner} = Machina.GameAssignerSup.add_assigner(scope)
        assigner
    end
  end
end
