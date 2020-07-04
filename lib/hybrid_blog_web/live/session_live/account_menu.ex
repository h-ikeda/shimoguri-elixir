defmodule HybridBlogWeb.SessionLive.AccountMenu do
  use HybridBlogWeb, :live_view
  alias HybridBlog.Accounts
  @impl true
  def mount(:not_mounted_at_router, %{"current_user" => uid}, socket) do
    %{name: name, picture: picture} = Accounts.get_user!(uid)
    if connected?(socket), do: HybridBlogWeb.Endpoint.subscribe("user:#{uid}")
    {:ok, assign(socket, uid: uid, name: name, picture: picture, menu_open: false)}
  end

  @impl true
  def handle_event("toggle", _params, %{assigns: %{menu_open: menu_open}} = socket) do
    {:noreply, assign(socket, menu_open: !menu_open)}
  end

  @impl true
  def handle_info(
        %{topic: "user:" <> uid, event: "change", payload: attrs},
        %{assigns: %{uid: uid}} = socket
      ) do
    {:noreply, assign(socket, attrs)}
  end
end
