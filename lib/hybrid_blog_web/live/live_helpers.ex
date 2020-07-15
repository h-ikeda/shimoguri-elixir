defmodule HybridBlogWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  alias Phoenix.LiveView
  alias HybridBlog.Accounts
  @type socket :: LiveView.Socket.t()
  @doc """
  Renders a component inside the `HybridBlogWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, HybridBlogWeb.UserLive.FormComponent,
        id: @user.id || :new,
        action: @live_action,
        user: @user,
        return_to: Routes.user_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, HybridBlogWeb.ModalComponent, modal_opts)
  end

  @spec assign_current_user(socket, map) :: LiveView.Socket.t()
  def assign_current_user(socket, %{"current_user_id" => id}) do
    LiveView.assign_new(socket, :current_user, fn -> Accounts.get_user_with_roles!(id) end)
  end

  def assign_current_user(socket, _session), do: socket

  @spec ensure_permitted(map, binary) :: :ok | {:error, :not_authenticated | :not_authorized}
  def ensure_permitted(%{current_user: current_user}, permission) do
    if permission in Accounts.permissions(current_user), do: :ok, else: {:error, :not_authorized}
  end

  def ensure_permitted(_socket, _permission), do: {:error, :not_authenticated}
end
