defmodule HybridBlogWeb.UserLive.Show do
  use HybridBlogWeb, :live_view

  alias HybridBlog.Accounts

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_current_user(socket, session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: live_action}} = socket) do
    if live_action == :show ||
         ensure_current_user?(socket.assigns, id) ||
         ensure_permitted(socket.assigns, "edit_users") == :ok do
      socket =
        if ensure_current_user?(socket.assigns, id) ||
             ensure_permitted(socket.assigns, "edit_user_roles") == :ok do
          assign(socket, :show_roles, true)
        else
          assign(socket, :show_roles, false)
        end

      {:noreply,
       socket
       |> assign(:page_title, page_title(live_action))
       |> assign(:user, Accounts.get_user_with_roles!(id))}
    else
      {:noreply, push_redirect(socket, to: Routes.user_show_path(socket, :show, id))}
    end
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"

  defp ensure_current_user?(%{current_user: %{id: id}}, id), do: true
  defp ensure_current_user?(_assigns, _id), do: false
end
