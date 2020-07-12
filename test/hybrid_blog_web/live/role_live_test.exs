defmodule HybridBlogWeb.RoleLiveTest do
  use HybridBlogWeb.ConnCase

  import Phoenix.LiveViewTest

  alias HybridBlog.Accounts

  @create_attrs %{name: "some name", permissions: ["delete_users"]}
  @update_attrs %{name: "some updated name", permissions: ["list_users"]}
  @invalid_attrs %{name: nil}

  defp fixture(:role) do
    {:ok, role} = Accounts.create_role(@create_attrs)
    role
  end

  defp create_role(_) do
    role = fixture(:role)
    %{role: role}
  end

  describe "Index" do
    setup [:create_role]

    test "lists all roles", %{conn: conn, role: role} do
      {:ok, _index_live, html} = live(conn, Routes.role_index_path(conn, :index))

      assert html =~ "Listing Roles"
      assert html =~ Enum.join(role.permissions, ", ")
    end

    test "saves new role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))

      assert index_live |> element("a", "New Role") |> render_click() =~
               "New Role"

      assert_patch(index_live, Routes.role_index_path(conn, :new))

      assert index_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.role_index_path(conn, :index))

      assert html =~ "Role created successfully"
      assert html =~ "delete_users"
    end

    test "updates role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))

      assert index_live |> element("#role-#{role.id} a", "Edit") |> render_click() =~
               "Edit Role"

      assert_patch(index_live, Routes.role_index_path(conn, :edit, role))

      assert index_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#role-form", role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.role_index_path(conn, :index))

      assert html =~ "Role updated successfully"
      assert html =~ "list_users"
    end

    test "deletes role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, Routes.role_index_path(conn, :index))

      assert index_live |> element("#role-#{role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#role-#{role.id}")
    end
  end

  describe "Show" do
    setup [:create_role]

    test "displays role", %{conn: conn, role: role} do
      {:ok, _show_live, html} = live(conn, Routes.role_show_path(conn, :show, role))

      assert html =~ "Show Role"
      assert html =~ Enum.join(role.permissions, ", ")
    end

    test "updates role within modal", %{conn: conn, role: role} do
      {:ok, show_live, _html} = live(conn, Routes.role_show_path(conn, :show, role))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Role"

      assert_patch(show_live, Routes.role_show_path(conn, :edit, role))

      assert show_live
             |> form("#role-form", role: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#role-form", role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))

      assert html =~ "Role updated successfully"
      assert html =~ "list_users"
    end
  end
end
