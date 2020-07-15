defmodule HybridBlogWeb.RoleLive.Show do
  use HybridBlogWeb, :live_view

  alias HybridBlog.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    case ensure_permitted(socket.assigns, "list_roles") do
      :ok -> {:ok, socket}
      {:error, _} -> {:ok, redirect(socket, to: Routes.page_path(socket, :index))}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:role, Accounts.get_role!(id))}
  end

  defp page_title(:show), do: "Show Role"
  defp page_title(:edit), do: "Edit Role"
end
