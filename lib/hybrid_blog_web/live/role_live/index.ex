defmodule HybridBlogWeb.RoleLive.Index do
  use HybridBlogWeb, :live_view
  alias HybridBlog.Accounts
  @impl true
  def mount(_params, session, socket) do
    {:ok, socket |> assign_current_user(session) |> assign_roles()}
  end

  defp assign_roles(%{assigns: assigns} = socket) do
    if has_permission?(assigns, "list_roles") do
      socket |> assign(:roles, Accounts.list_roles())
    else
      socket |> redirect(to: Routes.page_path(socket, :index))
    end
  end
end
