defmodule HybridBlogWeb.UserLive.Show do
  use HybridBlogWeb, :live_view
  alias HybridBlogWeb.Endpoint
  alias HybridBlog.Accounts
  @type socket :: Phoenix.LiveView.Socket.t()
  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket =
      socket
      |> assign_current_user(session)
      |> assign_locale(session)
      |> assign(user: Accounts.get_user_with_roles!(id), form_id: "user-form")

    if connected?(socket), do: Endpoint.subscribe("user:#{id}")
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{user: %{id: id}}} = socket) do
    handle_action(socket)
  end

  defp handle_action(%{assigns: %{live_action: :show} = assigns} = socket) do
    {:noreply, socket |> assign(:user_editable, user_editable?(assigns))}
  end

  defp handle_action(%{assigns: %{live_action: :edit, user: user} = assigns} = socket) do
    socket =
      if user_editable?(assigns) do
        socket
        |> assign_new_roles()
        |> assign(
          changeset: Accounts.change_user(user),
          user_role_editable: user_role_editable?(assigns)
        )
      else
        socket |> push_patch(to: Routes.i18n_user_show_path(socket, :show, assigns.locale, user))
      end

    {:noreply, socket}
  end

  @spec assign_new_roles(socket) :: socket
  defp assign_new_roles(%{assigns: assigns} = socket) do
    if user_role_editable?(assigns) do
      socket
      |> assign_new(:roles, fn ->
        Endpoint.subscribe("roles")
        Accounts.list_roles()
      end)
    else
      socket
    end
  end

  @impl true
  def handle_info(
        %{topic: "user:" <> id, event: "change", payload: user},
        %{assigns: %{user: %{id: id}}} = socket
      ) do
    {:noreply, socket |> assign(:user, user)}
  end

  def handle_info(%{topic: "roles", event: "add", payload: role}, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(:roles, [role | assigns.roles])}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, %{assigns: assigns} = socket) do
    changeset = change_user(assigns, user_params)
    {:noreply, socket |> assign(:changeset, %{changeset | action: :validate})}
  end

  def handle_event("save", %{"user" => user_params}, %{assigns: assigns} = socket) do
    socket =
      if user_editable?(assigns) do
        case update_user(assigns, user_params) do
          {:ok, user} ->
            Endpoint.broadcast_from(self(), "user:#{user.id}", "change", user)

            socket
            |> assign(:user, user)
            |> put_flash(:info, gettext("The user was updated successfully."))
            |> push_patch(to: Routes.i18n_user_show_path(socket, :show, assigns.locale, user))

          {:error, %Ecto.Changeset{} = changeset} ->
            socket |> assign(:changeset, changeset)
        end
      else
        socket
        |> put_flash(:error, gettext("Permission denied."))
        |> push_patch(to: Routes.i18n_user_show_path(socket, :show, assigns.locale, assigns.user))
      end

    {:noreply, socket}
  end

  defp change_user(assigns, user_params) do
    if user_role_editable?(assigns) do
      Accounts.change_user(assigns.user, Map.put_new(user_params, "role_ids", []), assigns)
    else
      Accounts.change_user(assigns.user, user_params)
    end
  end

  defp update_user(assigns, user_params) do
    if user_role_editable?(assigns) do
      Accounts.update_user(assigns.user, Map.put_new(user_params, "role_ids", []), assigns)
    else
      Accounts.update_user(assigns.user, user_params)
    end
  end

  @spec user_editable?(map) :: boolean
  defp user_editable?(%{current_user: %{id: id}, user: %{id: id}}), do: true
  defp user_editable?(assigns), do: has_permission?(assigns, "edit_users")
  @spec user_role_editable?(map) :: boolean
  defp user_role_editable?(assigns), do: has_permission?(assigns, "edit_user_roles")
end
