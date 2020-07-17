defmodule HybridBlogWeb.UserLive.Index do
  use HybridBlogWeb, :live_view

  alias HybridBlog.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    case ensure_permitted(socket.assigns, "list_users") do
      :ok -> {:ok, assign(socket, users: list_users())}
      {:error, _} -> {:ok, redirect(socket, to: Routes.page_path(socket, :index))}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user_with_roles!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case ensure_permitted(socket.assigns, "delete_users") do
      :ok ->
        user = Accounts.get_user!(id)
        {:ok, _} = Accounts.delete_user(user)

        {:noreply, assign(socket, :users, list_users())}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp list_users do
    Accounts.list_users()
  end
end
