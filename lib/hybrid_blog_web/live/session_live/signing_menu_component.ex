defmodule HybridBlogWeb.SessionLive.SigningMenuComponent do
  use HybridBlogWeb, :live_component
  @impl true
  def mount(socket) do
    {:ok, assign(socket, dialog_open: false)}
  end

  @impl true
  def handle_event("toggle", _, %{assigns: %{dialog_open: dialog_open}} = socket) do
    {:noreply, assign(socket, dialog_open: !dialog_open)}
  end
end
