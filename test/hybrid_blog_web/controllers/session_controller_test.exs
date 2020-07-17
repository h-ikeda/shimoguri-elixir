defmodule HybridBlogWeb.SessionControllerTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory

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
    setup do
      {:ok, %{user: insert!(:user)}}
    end

    test "removes current_user ID from session", %{conn: conn, user: user} do
      conn = conn |> init_test_session(%{live_socket_id: user.id}) |> get("/auth/signout")
      assert get_session(conn, :current_user) == nil
    end

    test "redirects to index page", %{conn: conn, user: user} do
      conn = conn |> init_test_session(%{live_socket_id: user.id}) |> get("/auth/signout")
      assert redirected_to(conn) == "/"
    end
  end

  describe "GET /auth/google/callback" do
    setup do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "POST", "/oauth2/v4/token", fn bypass_conn ->
        bypass_conn
        |> put_resp_content_type("application/json")
        |> send_resp(:ok, "{\"access_token\":\"access_token\"}")
      end)

      Bypass.expect_once(bypass, "GET", "/oauth2/v3/userinfo", fn bypass_conn ->
        bypass_conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          :ok,
          "{\"sub\":\"110248495921238986420\",\"name\":\"John Smith\",\"picture\":\"https://lh4.googleusercontent.com/-kw-iMgD_j34/AAAAAAAAAAA/AAAAAAAAAAA/P1YY23tzesZ/photo.jpg\"}"
        )
      end)

      Application.put_env(:hybrid_blog, :assent_providers,
        google:
          Keyword.put(
            Application.get_env(:hybrid_blog, :assent_providers)[:google],
            :site,
            "http://localhost:#{bypass.port}"
          )
      )
    end

    test "creates an user and puts current_user ID into the session", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{assent_session_params: %{google: %{state: "rstuv34567"}}})
        |> get("/auth/google/callback?code=abcde12345&state=rstuv34567")

      [user] = HybridBlog.Accounts.list_users()
      assert get_session(conn, :current_user_id) == user.id
      assert user.name == "John Smith"

      assert user.picture ==
               "https://lh4.googleusercontent.com/-kw-iMgD_j34/AAAAAAAAAAA/AAAAAAAAAAA/P1YY23tzesZ/photo.jpg"
    end

    test "does not overwrite the user but puts current_user ID into the session", %{conn: conn} do
      {:ok, %{id: user_id}} =
        HybridBlog.Accounts.create_user(
          %{
            name: "Jane Doe",
            picture:
              "https://lh4.googleusercontent.com/-kw-iMgD_j34/BBBBBBBBBB/CCCCCCCCCC/P1YY23tzesZ/photo.jpg"
          },
          google_sub: "110248495921238986420"
        )

      conn =
        conn
        |> init_test_session(%{assent_session_params: %{google: %{state: "pqrst23456"}}})
        |> get("/auth/google/callback?code=bcdef56789&state=pqrst23456")

      assert get_session(conn, :current_user_id) == user_id
      user = HybridBlog.Accounts.get_user!(user_id)
      assert user.name == "Jane Doe"

      assert user.picture ==
               "https://lh4.googleusercontent.com/-kw-iMgD_j34/BBBBBBBBBB/CCCCCCCCCC/P1YY23tzesZ/photo.jpg"
    end

    test "redirects to index page", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{assent_session_params: %{google: %{state: "hijkl34567"}}})
        |> get("/auth/google/callback?code=fghij45678&state=hijkl34567")

      assert redirected_to(conn) == "/"
    end
  end
end
