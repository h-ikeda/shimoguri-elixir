defmodule HodonoWeb.PageController do
  use HodonoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
