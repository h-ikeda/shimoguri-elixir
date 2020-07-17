defmodule HybridBlogWeb.UserLiveTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory
  import Phoenix.LiveViewTest

  describe "Index" do
    test "redirects to / without authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.user_index_path(conn, :index))
    end

    test "redirects to / without authorization", %{conn: conn} do
      permissions = random_role_permissions() |> List.delete("list_users")
      user = insert!(:user, roles: [build(:role, permissions: permissions)])
      conn = init_test_session(conn, %{current_user_id: user.id})
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.user_index_path(conn, :index))
    end

    test "lists all users", %{conn: conn} do
      user1 = insert!(:user)
      user2 = insert!(:user)
      user3 = insert!(:user)
      current_user = insert!(:user, roles: [build(:role, permissions: ["list_users"])])
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, _index_live, html} = live(conn, Routes.user_index_path(conn, :index))
      assert html =~ "Listing Users"
      assert html =~ user1.name
      assert html =~ user2.name
      assert html =~ user3.name
    end

    test "redirects to index when try to update an user without authorization", %{conn: conn} do
      user = insert!(:user)
      current_user = insert!(:user, roles: [build(:role, permissions: ["list_users"])])
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert index_live |> element("#user-#{user.id} a", "Edit") |> render_click() =~ "Edit User"
      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: %{name: unique_user_name(), picture: unique_user_picture()})
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      refute html =~ "User updated successfully"
      assert html =~ user.name
      assert html =~ user.picture
    end

    test "updates user in listing when current_user has an edit_users permission", %{conn: conn} do
      user = insert!(:user)

      current_user =
        insert!(:user, roles: [build(:role, permissions: ["list_users", "edit_users"])])

      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert index_live |> element("#user-#{user.id} a", "Edit") |> render_click() =~ "Edit User"
      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))
      name = unique_user_name()
      picture = unique_user_picture()

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: %{name: name, picture: picture})
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      assert html =~ "User updated successfully"
      assert html =~ name
      assert html =~ picture
    end

    test "updates current_user in listing", %{conn: conn} do
      current_user = insert!(:user, roles: [build(:role, permissions: ["list_users"])])
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))

      assert index_live |> element("#user-#{current_user.id} a", "Edit") |> render_click() =~
               "Edit User"

      assert_patch(index_live, Routes.user_index_path(conn, :edit, current_user))
      name = unique_user_name()
      picture = unique_user_picture()

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: %{name: name, picture: picture})
        |> render_submit()
        |> follow_redirect(conn, Routes.user_index_path(conn, :index))

      assert html =~ "User updated successfully"
      assert html =~ name
      assert html =~ picture
    end

    test "validates the name not to be empty", %{conn: conn} do
      user = insert!(:user)

      current_user =
        insert!(:user, roles: [build(:role, permissions: ["list_users", "edit_users"])])

      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert index_live |> element("#user-#{user.id} a", "Edit") |> render_click() =~ "Edit User"
      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))

      assert index_live
             |> form("#user-form", user: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"
    end

    test "validates the picture not to be empty", %{conn: conn} do
      user = insert!(:user)

      current_user =
        insert!(:user, roles: [build(:role, permissions: ["list_users", "edit_users"])])

      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert index_live |> element("#user-#{user.id} a", "Edit") |> render_click() =~ "Edit User"
      assert_patch(index_live, Routes.user_index_path(conn, :edit, user))

      assert index_live
             |> form("#user-form", user: %{picture: ""})
             |> render_change() =~ "can&apos;t be blank"
    end

    test "redirects to index when try to delete an user without authorization", %{conn: conn} do
      user = insert!(:user)
      current_user = insert!(:user, roles: [build(:role, permissions: ["list_users"])])
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert index_live |> element("#user-#{user.id} a", "Delete") |> render_click()
      assert has_element?(index_live, "#user-#{user.id}")
    end

    test "deletes user when current_user has a delete_users permission", %{conn: conn} do
      user = insert!(:user)

      current_user =
        insert!(:user, roles: [build(:role, permissions: ["list_users", "delete_users"])])

      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, index_live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert index_live |> element("#user-#{user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user-#{user.id}")
    end
  end

  describe "Show" do
    test "displays the user without roles when unauthenticated", %{conn: conn} do
      user = insert!(:user)
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert html =~ "Show User"
      refute html =~ "Roles"
    end

    test "displays the user without roles when unauthorized", %{conn: conn} do
      user = insert!(:user)
      current_user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert html =~ "Show User"
      refute html =~ "Roles"
    end

    test "displays the current user with roles", %{conn: conn} do
      current_user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, current_user))
      assert html =~ "Show User"
      assert html =~ "Roles"
    end

    test "displays the user with roles when authorized", %{conn: conn} do
      user = insert!(:user)
      current_user = insert!(:user, roles: [build(:role, permissions: ["edit_user_roles"])])
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, _show_live, html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert html =~ "Show User"
      assert html =~ "Roles"
    end

    test "redirects to show when try to update the user without authorization", %{conn: conn} do
      user = insert!(:user)
      current_user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, show_live, _html} = live(conn, Routes.user_show_path(conn, :show, user))

      assert {:ok, _, _html} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))
    end

    test "updates the user within authorization", %{conn: conn} do
      user = insert!(:user)
      current_user = insert!(:user, roles: [build(:role, permissions: ["edit_users"])])
      conn = init_test_session(conn, %{current_user_id: current_user.id})
      {:ok, show_live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert show_live |> element("a", "Edit") |> render_click() =~ "Edit User"
      assert_patch(show_live, Routes.user_show_path(conn, :edit, user))

      assert show_live
             |> form("#user-form", user: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      name = unique_user_name()
      picture = unique_user_picture()

      {:ok, _, html} =
        show_live
        |> form("#user-form", user: %{name: name, picture: picture})
        |> render_submit()
        |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))

      assert html =~ "User updated successfully"
      assert html =~ name
      assert html =~ picture
    end
  end
end
