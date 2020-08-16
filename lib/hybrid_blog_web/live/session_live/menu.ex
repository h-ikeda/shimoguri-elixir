defmodule HybridBlogWeb.SessionLive.Menu do
  use HybridBlogWeb, :live_view
  @impl true
  def mount(:not_mounted_at_router, %{"current_user_id" => current_user_id} = session, socket) do
    if connected?(socket), do: HybridBlogWeb.Endpoint.subscribe("user:#{current_user_id}")

    {:ok,
     socket
     |> assign_current_user(session)
     |> assign_locale(session)
     |> assign(:authenticated, true), layout: {HybridBlogWeb.LayoutView, "live_plain.html"}}
  end

  def mount(:not_mounted_at_router, session, socket) do
    {:ok, socket |> assign_locale(session) |> assign(:authenticated, false),
     layout: {HybridBlogWeb.LayoutView, "live_plain.html"}}
  end

  @impl true
  def handle_info(
        %{topic: "user:" <> id, event: "change", payload: user},
        %{assigns: %{current_user: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :current_user, user)}
  end
end
