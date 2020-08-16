defmodule HybridBlogWeb.SessionLiveTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory
  import Phoenix.LiveViewTest
  alias HybridBlogWeb.SessionLive
  @locale "en"
  describe "Signing menu" do
    setup %{conn: conn} do
      %{conn: conn |> init_test_session(%{locale: @locale})}
    end

    test "shows the sign in / up button", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)
      assert view |> has_element?("button.material-icons", "login")
    end

    test "shows the sign in / up dialog", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)
      result = view |> element("button.material-icons", "login") |> render_click()
      assert result =~ "Sign in / Sign up"
      assert result =~ "Sign in with Google"
    end
  end

  describe "Account menu" do
    setup %{conn: conn} do
      user = insert!(:user)
      conn = conn |> init_test_session(%{current_user_id: user.id, locale: @locale})
      %{conn: conn, user: user}
    end

    test "displays the user picture and name", %{conn: conn, user: user} do
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)
      assert view |> has_element?("button img[src=\"#{user.picture}\"]")
      assert view |> has_element?("button span", user.name)
    end

    test "shows the links to the profile and the sign out", %{conn: conn, user: user} do
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)
      result = view |> element("button", user.name) |> render_click()
      assert result =~ "Profile"
      assert result =~ Routes.i18n_user_show_path(conn, :show, @locale, user)
      assert result =~ "Sign out"
      assert result =~ Routes.session_path(conn, :sign_out)
    end
  end
end
