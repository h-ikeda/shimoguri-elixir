defmodule HybridBlogWeb.SessionLive.Menu do
  use HybridBlogWeb, :live_view
  @impl true
  def mount(:not_mounted_at_router, %{"current_user_id" => current_user_id}, socket) do
    %{name: name, picture: picture} = HybridBlog.Accounts.get_user!(current_user_id)
    if connected?(socket), do: HybridBlogWeb.Endpoint.subscribe("user:#{current_user_id}")
    {:ok, assign(socket, user_id: current_user_id, name: name, picture: picture)}
  end

  def mount(:not_mounted_at_router, _session, socket) do
    {:ok, assign(socket, user_id: nil)}
  end

  @impl true
  def handle_info(
        %{topic: "user:" <> user_id, event: "change", payload: attrs},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    {:noreply, assign(socket, attrs)}
  end
end
