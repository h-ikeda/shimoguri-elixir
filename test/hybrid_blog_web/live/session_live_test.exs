defmodule HybridBlogWeb.SessionLiveTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory
  import Phoenix.LiveViewTest
  alias HybridBlogWeb.SessionLive
  describe "Signing menu" do
    test "shows the sign in / up button", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, SessionLive.Menu)
      assert html =~ "Sign in / Sign up"
    end

    test "shows the sign in / up dialog", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)

      assert view |> element("button", "Sign in / Sign up") |> render_click() =~
               "Sign in with Google"
    end
  end

  describe "Account menu" do
    test "displays the user picture and name", %{conn: conn} do
      user = insert!(:user)
      conn = conn |> init_test_session(%{current_user_id: user.id})
      {:ok, _view, html} = live_isolated(conn, SessionLive.Menu)
      assert html =~ user.picture
      assert html =~ user.name
    end

    test "shows the sign out button", %{conn: conn} do
      user = insert!(:user)
      conn = conn |> init_test_session(%{current_user_id: user.id})
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)

      assert view |> element("button", user.name) |> render_click() =~
               Routes.session_path(conn, :sign_out)
    end
  end
end
