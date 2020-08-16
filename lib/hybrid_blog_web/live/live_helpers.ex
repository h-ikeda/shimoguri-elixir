defmodule HybridBlogWeb.LiveHelpers do
  import Phoenix.LiveView
  alias HybridBlog.Accounts
  @type socket :: LiveView.Socket.t()
  @spec assign_current_user(socket, map) :: socket
  def assign_current_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      case Map.fetch(session, "current_user_id") do
        {:ok, id} -> Accounts.get_user_with_roles!(id)
        :error -> nil
      end
    end)
  end

  @spec assign_locale(socket, map) :: socket
  def assign_locale(socket, session) do
    assign_new(socket, :locale, fn ->
      locale = session["locale"]
      Cldr.put_locale(HybridBlogWeb.Cldr, locale)
      Gettext.put_locale(locale)
      locale
    end)
  end

  @spec has_permission?(map, binary) :: boolean
  def has_permission?(%{current_user: current_user}, permission) when is_binary(permission) do
    if current_user, do: permission in Accounts.permissions(current_user), else: false
  end
end
