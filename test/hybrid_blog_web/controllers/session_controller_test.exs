defmodule HybridBlogWeb.SessionControllerTest do
  use HybridBlogWeb.ConnCase

  describe "GET /api/authorize_url" do
    test "returns a JSON containing authorize URLs", %{conn: conn} do
      conn = get(conn, "/api/authorize_url")

      assert %{"google" => "https://accounts.google.com/o/oauth2/v2/auth?" <> _} =
               json_response(conn, :ok)
    end

    test "sets the session params", %{conn: conn} do
      conn = get(conn, "/api/authorize_url")
      assert %{google: %{state: "" <> _}} = get_session(conn, :assent_session_params)
    end
  end

  describe "GET /auth/signout" do
    test "removes current_user id from session", %{conn: conn} do
      {:ok, %{id: user_id}} = HybridBlog.Accounts.create_user(%{name: "name", picture: "pict"})
      conn = conn |> init_test_session(%{current_user: user_id}) |> get("/auth/signout")
      assert get_session(conn, :current_user) == nil
    end

    test "redirects to index page", %{conn: conn} do
      conn = get(conn, "/auth/signout")
      assert redirected_to(conn) == "/"
    end
  end
end
