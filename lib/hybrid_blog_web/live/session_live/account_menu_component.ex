defmodule HybridBlogWeb.SessionLive.AccountMenuComponent do
  use HybridBlogWeb, :live_component
  @impl true
  def mount(socket) do
    {:ok, assign(socket, menu_open: false)}
  end

  @impl true
  def handle_event("toggle", _params, %{assigns: %{menu_open: menu_open}} = socket) do
    {:noreply, assign(socket, menu_open: !menu_open)}
  end
end
