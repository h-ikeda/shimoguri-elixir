defmodule HybridBlogWeb.PageControllerTest do
  use HybridBlogWeb.ConnCase

  describe "respecting canonical host" do
    test "GET non canonical host root", %{conn: conn} do
      conn = get(conn, "http://example.com")
      assert redirected_to(conn, :moved_permanently) == "http://localhost"
    end
    
    test "GET non canonical host path", %{conn: conn} do
      conn = get(conn, "http://example.com/path/to/content")
      assert redirected_to(conn, :moved_permanently) == "http://localhost/path/to/content"
    end

    test "GET non canonical host with query", %{conn: conn} do
      conn = get(conn, "http://example.com?query=some")
      assert redirected_to(conn, :moved_permanently) == "http://localhost?query=some"
    end

    test "GET non canonical host via SSL", %{conn: conn} do
      conn = get(conn, "https://example.com")
      assert redirected_to(conn, :moved_permanently) == "https://localhost"
    end
  end

  describe "GET /" do
    test "\"Welcome to Phoenix\" in the body string", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    end

    test "title in the html", %{conn: conn} do
      conn = get(conn, "/")
      expected_title = Application.get_env(:hybrid_blog, :title)
      assert html_response(conn, 200) =~ "<title>#{expected_title}<\/title>"
    end
  end
end
