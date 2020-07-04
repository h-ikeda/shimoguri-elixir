defmodule HybridBlogWeb.SessionLive.SigningMenu do
  use HybridBlogWeb, :live_view
  @impl true
  def mount(:not_mounted_at_router, _session, socket) do
    {:ok, assign(socket, dialog_open: false)}
  end

  @impl true
  def handle_event("toggle", _, %{assigns: %{dialog_open: dialog_open}} = socket) do
    {:noreply, assign(socket, dialog_open: !dialog_open)}
  end
end
