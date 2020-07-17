defmodule HybridBlogWeb.UserLive.FormComponent do
  use HybridBlogWeb, :live_component

  alias HybridBlog.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :roles, Accounts.list_roles() |> Enum.map(&{&1.name, &1.id}))}
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:disable_roles, ensure_permitted(assigns, "edit_user_roles") != :ok)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp ensure_current_user?(%{current_user: %{id: id}, id: id}), do: true
  defp ensure_current_user?(_assigns), do: false

  defp save_user(socket, :edit, %{"roles" => roles} = user_params) do
    user_params =
      case ensure_permitted(socket.assigns, "edit_user_roles") do
        :ok ->
          Map.put(
            user_params,
            "roles",
            Accounts.get_roles(roles)
          )

        {:error, _} ->
          Map.delete(user_params, "roles")
      end

    with true <-
           ensure_current_user?(socket.assigns) ||
             ensure_permitted(socket.assigns, "edit_users") == :ok,
         {:ok, user} <- Accounts.update_user(socket.assigns.user, user_params) do
      :ok =
        HybridBlogWeb.Endpoint.broadcast_from(
          self(),
          "user:#{user.id}",
          "change",
          Map.take(user, [:name, :picture])
        )

      {:noreply,
       socket
       |> put_flash(:info, "User updated successfully")
       |> push_redirect(to: socket.assigns.return_to)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      false ->
        {:noreply, push_redirect(socket, to: socket.assigns.return_to)}
    end
  end

  defp save_user(socket, :edit, user_params) do
    save_user(socket, :edit, Map.put(user_params, "roles", []))
  end

  defp save_user(socket, :new, user_params) do
    with :ok <- ensure_permitted(socket.assigns, "create_users"),
         {:ok, _user} <- Accounts.create_user(user_params) do
      {:noreply,
       socket
       |> put_flash(:info, "User created successfully")
       |> push_redirect(to: socket.assigns.return_to)}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:noreply, assign(socket, changeset: changeset)}
      {:error, _} -> {:noreply, push_redirect(socket, to: socket.assigns.return_to)}
    end
  end
end
