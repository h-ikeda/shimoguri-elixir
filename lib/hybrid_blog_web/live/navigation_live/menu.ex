defmodule HybridBlogWeb.NavigationLive.Menu do
  use HybridBlogWeb, :live_view
  @impl true
  def mount(:not_mounted_at_router, session, socket) do
    socket =
      socket
      |> assign_current_user(session)
      |> assign_locale(session)
      |> assign(:drawer_open, false)

    {:ok, socket, layout: {HybridBlogWeb.LayoutView, "live_plain.html"}}
  end

  @impl true
  def handle_event("toggle", _params, %{assigns: %{drawer_open: drawer_open}} = socket) do
    {:noreply, assign(socket, :drawer_open, !drawer_open)}
  end
end