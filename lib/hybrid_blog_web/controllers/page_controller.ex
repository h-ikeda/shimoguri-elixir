defmodule HybridBlogWeb.PageController do
  use HybridBlogWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
