defmodule HybridBlogWeb.RoleLive.Index do
  use HybridBlogWeb, :live_view

  alias HybridBlog.Accounts
  alias HybridBlog.Accounts.Role

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    case ensure_permitted(socket.assigns, "list_roles") do
      :ok -> {:ok, assign(socket, :roles, list_roles())}
      {:error, _} -> {:ok, redirect(socket, to: Routes.page_path(socket, :index))}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Role")
    |> assign(:role, Accounts.get_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Role")
    |> assign(:role, %Role{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Roles")
    |> assign(:role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case ensure_permitted(socket.assigns, "delete_roles") do
      :ok ->
        role = Accounts.get_role!(id)
        {:ok, _} = Accounts.delete_role(role)

        {:noreply, assign(socket, :roles, list_roles())}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp list_roles do
    Accounts.list_roles()
  end
end
