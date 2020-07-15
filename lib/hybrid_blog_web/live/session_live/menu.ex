defmodule HybridBlogWeb.SessionLive.Menu do
  use HybridBlogWeb, :live_view
  @impl true
  def mount(:not_mounted_at_router, %{"current_user_id" => current_user_id} = session, socket) do
    if connected?(socket), do: HybridBlogWeb.Endpoint.subscribe("user:#{current_user_id}")
    {:ok, socket |> assign_current_user(session) |> assign(:authenticated, true)}
  end

  def mount(:not_mounted_at_router, _session, socket) do
    {:ok, assign(socket, :authenticated, false)}
  end

  @impl true
  def handle_info(
        %{topic: "user:" <> id, event: "change", payload: attrs},
        %{assigns: %{current_user: %{id: id} = current_user}} = socket
      ) do
    {:noreply, assign(socket, :current_user, Map.merge(current_user, attrs))}
  end
end
