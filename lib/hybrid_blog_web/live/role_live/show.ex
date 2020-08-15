defmodule HybridBlogWeb.RoleLive.Show do
  use HybridBlogWeb, :live_view
  alias HybridBlog.Accounts
  alias HybridBlogWeb.Endpoint
  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_current_user(session)
      |> assign(form_id: "role-form", permissions: Accounts.Role.permissions())

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: :show} = assigns} = socket) do
    socket =
      if has_permission?(assigns, "list_roles") do
        socket |> assign_role(id)
      else
        socket |> redirect(to: Routes.page_path(socket, :index))
      end

    {:noreply, socket}
  end

  def handle_params(%{"id" => id}, _, %{assigns: %{live_action: :edit} = assigns} = socket) do
    socket =
      if has_permission?(assigns, "edit_roles") do
        socket |> assign_role(id) |> assign_changeset()
      else
        socket |> push_patch(to: Routes.role_show_path(socket, :show, id))
      end

    {:noreply, socket}
  end

  def handle_params(_params, _, %{assigns: %{live_action: :new} = assigns} = socket) do
    socket =
      if has_permission?(assigns, "create_roles") do
        socket |> assign_new_role() |> assign_changeset()
      else
        socket |> push_redirect(to: Routes.role_index_path(socket, :index))
      end

    {:noreply, socket}
  end

  defp assign_role(%{assigns: %{role_id: id}} = socket, id), do: socket

  defp assign_role(%{assigns: %{role_id: old_id}} = socket, new_id) do
    Endpoint.unsubscribe("role:#{old_id}")
    Endpoint.subscribe("role:#{new_id}")
    socket |> assign(role_id: new_id, role: Accounts.get_role!(new_id))
  end

  defp assign_role(socket, id) do
    if connected?(socket), do: Endpoint.subscribe("role:#{id}")
    socket |> assign(role_id: id, role: Accounts.get_role!(id))
  end

  defp assign_new_role(socket), do: socket |> assign(:role, %Accounts.Role{})

  defp assign_changeset(%{assigns: %{role: role}} = socket) do
    socket |> assign(:changeset, Accounts.change_role(role))
  end

  @impl true
  def handle_event("delete", _params, %{assigns: %{role: role} = assigns} = socket) do
    socket =
      if has_permission?(assigns, "delete_roles") do
        case Accounts.delete_role(role) do
          {:ok, role} ->
            Endpoint.broadcast_from(self(), "roles", "remove", role)

            socket
            |> put_flash(:info, gettext("The role was deleted successfully."))
            |> push_redirect(to: Routes.role_index_path(socket, :index))
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("validate", %{"role" => role_params}, socket) do
    changeset =
      socket.assigns.role
      |> Accounts.change_role(role_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"role" => role_params}, socket) do
    save_role(socket, socket.assigns.live_action, role_params)
  end

  defp save_role(%{assigns: assigns} = socket, :edit, %{"permissions" => _} = role_params) do
    socket =
      if has_permission?(assigns, "edit_roles") do
        case Accounts.update_role(assigns.role, role_params) do
          {:ok, role} ->
            Endpoint.broadcast_from(self(), "role:#{role.id}", "change", role)

            socket
            |> assign(:role, role)
            |> put_flash(:info, gettext("The role was updated successfully."))
            |> push_patch(to: Routes.role_show_path(socket, :show, role))

          {:error, %Ecto.Changeset{} = changeset} ->
            socket |> assign(:changeset, changeset)
        end
      else
        socket |> push_patch(to: Routes.role_show_path(socket, :show, assigns.role))
      end

    {:noreply, socket}
  end

  defp save_role(%{assigns: assigns} = socket, :new, %{"permissions" => _} = role_params) do
    socket =
      if has_permission?(assigns, "create_roles") do
        case Accounts.create_role(role_params) do
          {:ok, role} ->
            Endpoint.broadcast_from(self(), "roles", "add", role)

            socket
            |> put_flash(:info, gettext("The role was created successfully."))
            |> push_patch(to: Routes.role_show_path(socket, :show, role))

          {:error, %Ecto.Changeset{} = changeset} ->
            socket |> assign(:changeset, changeset)
        end
      else
        socket |> push_redirect(to: Routes.role_index_path(socket, :index))
      end

    {:noreply, socket}
  end

  defp save_role(socket, action, role_params) do
    save_role(socket, action, Map.put(role_params, "permissions", []))
  end

  @impl true
  def handle_info(
        %{topic: "role:" <> id, event: "change", payload: role},
        %{assigns: %{role_id: id}} = socket
      ) do
    {:noreply, socket |> assign(:role, role)}
  end
end
