defmodule HybridBlogWeb.UserLiveTest do
  use HybridBlogWeb.ConnCase

  import Phoenix.LiveViewTest

  alias HybridBlog.Accounts

  @create_attrs %{name: "some name", picture: "some picture"}
  @update_attrs %{name: "some updated name", picture: "some updated picture"}
  @invalid_attrs %{name: nil, picture: nil}

  defp fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

  describe "Index" do
    setup [:create_user]

    test "lists all users without authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.user_index_path(conn, :index))
    end

    test "lists all users without authorization", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{current_user_id: user.id})
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.user_index_path(conn, :index))
    end

    test "lists all users", %{conn: conn, user: user} do
      {:ok, role} = Accounts.create_role(%{name: "User role", permissions: ["list_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, _index_live, html} = live(conn, Routes.user_index_path(conn, :index))

      assert html =~ "Listing Users"
    end

    test "updates user in listing without authorization", %{conn: conn, user: user} do
      {:ok, role} = Accounts.create_role(%{name: "User role", permissions: ["list_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#user-#{user.id} a", "Edit") |> render_click() =~
               "Edit User"

      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))

      assert index_live
             |> form("#user-form", user: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      refute html =~ "User updated successfully"
    end

    test "updates user in listing", %{conn: conn, user: user} do
      {:ok, role} =
        Accounts.create_role(%{name: "User role", permissions: ["list_users", "edit_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#user-#{user.id} a", "Edit") |> render_click() =~
               "Edit User"

      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))

      assert index_live
             |> form("#user-form", user: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      assert html =~ "User updated successfully"
    end

    test "deletes user in listing without authorization", %{conn: conn, user: user} do
      {:ok, role} =
        Accounts.create_role(%{name: "User role", permissions: ["list_users", "edit_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#user-#{user.id} a", "Delete") |> render_click()
      assert has_element?(index_live, "#user-#{user.id}")
    end

    test "deletes user in listing", %{conn: conn, user: user} do
      {:ok, role} =
        Accounts.create_role(%{name: "User role", permissions: ["list_users", "delete_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#user-#{user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user-#{user.id}")
    end
  end

  describe "Show" do
    setup [:create_user]

    test "displays user without authentication", %{conn: conn, user: user} do
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "Show User"
      refute html =~ "Roles"
    end

    test "displays user without authorization", %{conn: conn, user: user} do
      {:ok, %{id: id}} =
        Accounts.create_user(%{name: "current user", picture: "current-user-picture"})

      conn = init_test_session(conn, %{current_user_id: id})
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "Show User"
      refute html =~ "Roles"
    end

    test "displays current user", %{conn: conn, user: user} do
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "Show User"
      assert html =~ "Roles"
    end

    test "displays user", %{conn: conn, user: user} do
      {:ok, role} =
        Accounts.create_role(%{name: "User role", permissions: ["list_users", "delete_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "Show User"
      assert html =~ "Roles"
    end

    test "updates user within modal without authorization", %{conn: conn, user: user} do
      {:ok, show_live, _html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert {:ok, _, _html} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))
    end

    test "updates user within modal", %{conn: conn, user: user} do
      {:ok, role} =
        Accounts.create_role(%{name: "User role", permissions: ["edit_users"]})

      {:ok, user} =
        Accounts.update_user(HybridBlog.Repo.preload(user, :roles), %{"roles" => [role.id]})

      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, show_live, _html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User"

      assert_patch(show_live, Routes.user_show_path(conn, :edit, user))

      assert show_live
             |> form("#user-form", user: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#user-form", user: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "User updated successfully"
    end
  end
end
