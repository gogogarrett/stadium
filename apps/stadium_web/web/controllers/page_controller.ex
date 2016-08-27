defmodule StadiumWeb.PageController do
  use StadiumWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
