defmodule HybridBlogWeb.UserLive.Index do
  use HybridBlogWeb, :live_view
  alias HybridBlog.Accounts
  @impl true
  def mount(_params, session, socket) do
    {:ok, socket |> assign_current_user(session) |> assign_locale(session) |> assign_users()}
  end

  defp assign_users(%{assigns: assigns} = socket) do
    if has_permission?(assigns, "list_users") do
      socket |> assign(:users, Accounts.list_users())
    else
      socket |> redirect(to: Routes.i18n_page_path(socket, :index, assigns.locale))
    end
  end
end
