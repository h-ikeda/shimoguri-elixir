defmodule HybridBlogWeb.SessionLive.Status do
  use HybridBlogWeb, :live_view

  alias HybridBlog.Accounts
  alias HybridBlog.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, current_user: session["current_user"], dialog_open: false)}
  end

  @impl true
  def handle_event("open_dialog", _params, socket) do
    {:noreply, assign(socket, :dialog_open, true)}
  end

  @impl true
  def handle_event("close_dialog", _params, socket) do
    {:noreply, assign(socket, :dialog_open, false)}
  end
end
