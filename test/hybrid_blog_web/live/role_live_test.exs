defmodule HybridBlogWeb.RoleLiveTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory
  import Phoenix.LiveViewTest

  describe "Index" do
    test "redirects to / without authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.role_index_path(conn, :index))
    end

    test "redirects to / without authorization", %{conn: conn} do
      user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: user.id})
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.role_index_path(conn, :index))
    end

    test "lists all roles", %{conn: conn} do
      role1 = insert!(:role, permissions: random_role_permissions())
      role2 = insert!(:role, permissions: random_role_permissions())
      role3 = insert!(:role, permissions: random_role_permissions())
      role4 = insert!(:role, permissions: random_role_permissions())
      user_role = insert!(:role, permissions: ["list_roles"])
      user = insert!(:user, roles: [user_role])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, _index_live, html} = live(conn, Routes.role_index_path(conn, :index))
      assert html =~ "Listing Roles"
      assert html =~ role1.name
      assert html =~ Enum.join(role1.permissions, ", ")
      assert html =~ role2.name
      assert html =~ Enum.join(role2.permissions, ", ")
      assert html =~ role3.name
      assert html =~ Enum.join(role3.permissions, ", ")
      assert html =~ role4.name
      assert html =~ Enum.join(role4.permissions, ", ")
      assert html =~ user_role.name
      assert html =~ "list_roles"
    end

    test "rejects saving a new role without authorization", %{conn: conn} do
      user_role = insert!(:role, permissions: ["list_roles"])
      user = insert!(:user, roles: [user_role])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert index_live |> element("a", "New Role") |> render_click() =~ "New Role"
      assert_patch(index_live, Routes.role_index_path(conn, :new))

      assert index_live
             |> form("#role-form", role: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      name = unique_role_name()
      permissions = random_role_permissions()

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: %{name: name, permissions: permissions})
        |> render_submit()
        |> follow_redirect(conn, Routes.role_index_path(conn, :index))

      refute html =~ name
      refute html =~ Enum.join(permissions, ", ")
    end

    test "saves a new role", %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles", "create_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert index_live |> element("a", "New Role") |> render_click() =~ "New Role"
      assert_patch(index_live, Routes.role_index_path(conn, :new))

      assert index_live
             |> form("#role-form", role: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      name = unique_role_name()
      permissions = random_role_permissions()

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: %{name: name, permissions: permissions})
        |> render_submit()
        |> follow_redirect(conn, Routes.role_index_path(conn, :index))

      assert html =~ name
      assert html =~ Enum.join(permissions, ", ")
    end

    test "rejects updating a role in listing without authorization", %{conn: conn} do
      role = insert!(:role, permissions: random_role_permissions())
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert index_live |> element("#role-#{role.id} a", "Edit") |> render_click() =~ "Edit Role"
      assert_patch(index_live, Routes.role_index_path(conn, :edit, role))

      assert index_live
             |> form("#role-form", role: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#role-form",
          role: %{name: unique_role_name(), permissions: random_role_permissions()}
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.role_index_path(conn, :index))

      refute html =~ "Role updated successfully"
      assert html =~ role.name
      assert html =~ Enum.join(role.permissions, ", ")
    end

    test "updates role in listing", %{conn: conn} do
      role = insert!(:role)
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles", "edit_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert index_live |> element("#role-#{role.id} a", "Edit") |> render_click() =~ "Edit Role"
      assert_patch(index_live, Routes.role_index_path(conn, :edit, role))

      assert index_live
             |> form("#role-form", role: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      name = unique_role_name()
      permissions = random_role_permissions()

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: %{name: name, permissions: permissions})
        |> render_submit()
        |> follow_redirect(conn, Routes.role_index_path(conn, :index))

      assert html =~ "Role updated successfully"
      assert html =~ name
      assert html =~ Enum.join(permissions, ", ")
    end

    test "rejects deleting a role in listing without authorization", %{conn: conn} do
      role = insert!(:role)
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert index_live |> element("#role-#{role.id} a", "Delete") |> render_click()
      assert has_element?(index_live, "#role-#{role.id}")
    end

    test "deletes role in listing", %{conn: conn} do
      role = insert!(:role)
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles", "delete_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert index_live |> element("#role-#{role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#role-#{role.id}")
    end
  end

  describe "Show" do
    test "redirects to / without authentication", %{conn: conn} do
      role = insert!(:role)

      assert {:error, {:redirect, %{to: "/"}}} =
               live(conn, Routes.role_show_path(conn, :show, role))
    end

    test "redirects to / without authorization", %{conn: conn} do
      role = insert!(:role)
      user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: user.id})

      assert {:error, {:redirect, %{to: "/"}}} =
               live(conn, Routes.role_show_path(conn, :show, role))
    end

    test "displays role", %{conn: conn} do
      role = insert!(:role, permissions: random_role_permissions())
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, _show_live, html} = live(conn, Routes.role_show_path(conn, :show, role))
      assert html =~ "Show Role"
      assert html =~ role.name
      assert html =~ Enum.join(role.permissions, ", ")
    end

    test "rejects updating a role within modal without authorization", %{conn: conn} do
      role = insert!(:role, permissions: random_role_permissions())
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, show_live, _html} = live(conn, Routes.role_show_path(conn, :show, role))
      assert show_live |> element("a", "Edit") |> render_click() =~ "Edit Role"
      assert_patch(show_live, Routes.role_show_path(conn, :edit, role))

      assert show_live
             |> form("#role-form", role: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      name = unique_role_name()
      permissions = random_role_permissions()

      {:ok, _, html} =
        show_live
        |> form("#role-form", role: %{name: name, permissions: permissions})
        |> render_submit()
        |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))

      refute html =~ "Role updated successfully"
      refute html =~ name
      refute html =~ Enum.join(permissions, ", ")
      assert html =~ role.name
      assert html =~ Enum.join(role.permissions, ", ")
    end

    test "updates role within modal", %{conn: conn} do
      role = insert!(:role)
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles", "edit_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      {:ok, show_live, _html} = live(conn, Routes.role_show_path(conn, :show, role))
      assert show_live |> element("a", "Edit") |> render_click() =~ "Edit Role"
      assert_patch(show_live, Routes.role_show_path(conn, :edit, role))

      assert show_live
             |> form("#role-form", role: %{name: ""})
             |> render_change() =~ "can&apos;t be blank"

      name = unique_role_name()
      permissions = random_role_permissions()

      {:ok, _, html} =
        show_live
        |> form("#role-form", role: %{name: name, permissions: permissions})
        |> render_submit()
        |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))

      assert html =~ "Role updated successfully"
      assert html =~ name
      assert html =~ Enum.join(permissions, ", ")
    end
  end
end
