defmodule HybridBlogWeb.LayoutView do
  use HybridBlogWeb, :view
  @title Application.compile_env(:hybrid_blog, :title)
  @spec title(String.t() | nil) :: String.t()
  def title(nil), do: gettext(@title)
  def title(sub), do: "#{sub} | #{gettext(@title)}"
  @spec session_menu(Plug.Conn.t()) :: Plug.Conn.t()
  def session_menu(conn) do
    if Plug.Conn.get_session(conn, :current_user) do
      live_render(conn, HybridBlogWeb.SessionLive.AccountMenu)
    else
      live_render(conn, HybridBlogWeb.SessionLive.SigningMenu)
    end
  end
end
