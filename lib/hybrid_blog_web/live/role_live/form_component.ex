defmodule HybridBlogWeb.RoleLive.FormComponent do
  use HybridBlogWeb, :live_component

  alias HybridBlog.Accounts

  @impl true
  def update(%{role: role} = assigns, socket) do
    changeset = Accounts.change_role(role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"role" => role_params}, socket) do
    changeset =
      socket.assigns.role
      |> Accounts.change_role(role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"role" => role_params}, socket) do
    save_role(socket, socket.assigns.action, role_params)
  end

  defp save_role(socket, :edit, %{"permissions" => _} = role_params) do
    case Accounts.update_role(socket.assigns.role, role_params) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_role(socket, :new, %{"permissions" => _} = role_params) do
    case Accounts.create_role(role_params) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Role created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_role(socket, action, role_params) do
    save_role(socket, action, Map.put(role_params, "permissions", []))
  end
end
