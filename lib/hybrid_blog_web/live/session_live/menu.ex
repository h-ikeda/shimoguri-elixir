defmodule HybridBlogWeb.SessionLive.Menu do
  use HybridBlogWeb, :live_view
  alias HybridBlog.Accounts
  @impl true
  def mount(:not_mounted_at_router, %{"current_user_id" => current_user_id}, socket) do
    current_user = Accounts.get_user!(current_user_id)
    if connected?(socket), do: HybridBlogWeb.Endpoint.subscribe("user:#{current_user_id}")
    {:ok, assign(socket, current_user: current_user)}
  end

  def mount(:not_mounted_at_router, _session, socket) do
    {:ok, assign(socket, current_user: nil)}
  end

  @impl true
  def handle_info(
        %{topic: "user:" <> current_user_id, event: "change", payload: attrs},
        %{assigns: %{current_user: %{id: current_user_id} = current_user}} = socket
      ) do
    {:noreply, assign(socket, current_user: Map.merge(current_user, attrs))}
  end
end
