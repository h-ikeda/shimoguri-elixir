defmodule HybridBlogWeb.UserLive.FormComponent do
  use HybridBlogWeb, :live_component

  alias HybridBlog.Accounts

  @impl true
  def mount(socket) do
    roles = Accounts.list_roles() |> Enum.map(&{&1.name, &1.id})
    {:ok, assign(socket, roles: roles)}
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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

  defp save_user(socket, :edit, %{"roles" => _} = user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
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

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :edit, user_params) do
    save_user(socket, :edit, Map.put(user_params, "roles", []))
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
