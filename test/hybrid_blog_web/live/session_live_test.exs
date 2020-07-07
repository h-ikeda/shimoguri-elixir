defmodule HybridBlogWeb.SessionLiveTest do
  use HybridBlogWeb.ConnCase
  import Phoenix.LiveViewTest
  alias HybridBlog.Accounts
  alias HybridBlogWeb.SessionLive
  @user_attrs %{name: "some name", picture: "some picture"}
  defp fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

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
    setup [:create_user]

    test "displays the user picture and name", %{conn: conn, user: user} do
      conn = conn |> init_test_session(%{current_user_id: user.id})
      {:ok, _view, html} = live_isolated(conn, SessionLive.Menu)
      assert html =~ user.picture
      assert html =~ user.name
    end

    test "shows the sign out button", %{conn: conn, user: user} do
      conn = conn |> init_test_session(%{current_user_id: user.id})
      {:ok, view, _html} = live_isolated(conn, SessionLive.Menu)

      assert view |> element("button", user.name) |> render_click() =~
               Routes.session_path(conn, :sign_out)
    end
  end
end
