defmodule StadiumWeb.UserSocket do
  use Phoenix.Socket

  channel "game:*", StadiumWeb.GameChannel
  channel "lobby:*", StadiumWeb.LobbyChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(params, socket) do
    socket = assign(socket, :user_id, params["user_id"])

    {:ok, socket}
  end

  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
