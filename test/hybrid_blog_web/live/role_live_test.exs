defmodule HybridBlogWeb.RoleLiveTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory
  import Phoenix.LiveViewTest

  describe "without authentication :" do
    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.role_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) redirects to Page(:index)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :show, role))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :edit, role))
             |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))
    end

    test "Show(:new) redirects to Index(:index)", %{conn: conn} do
      assert live(conn, Routes.role_show_path(conn, :new))
             |> follow_redirect(conn, Routes.role_index_path(conn, :index))
    end
  end

  describe "without permissions :" do
    setup %{conn: conn} do
      user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.role_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) redirects to Page(:index)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :show, role))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :edit, role))
             |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))
    end

    test "Show(:new) redirects to Index(:index)", %{conn: conn} do
      assert live(conn, Routes.role_show_path(conn, :new))
             |> follow_redirect(conn, Routes.role_index_path(conn, :index))
    end
  end

  describe "with list_roles permission :" do
    setup %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Index(:index) lists all roles", %{conn: conn} do
      role1 = insert!(:role, permissions: random_role_permissions())
      role2 = insert!(:role, permissions: random_role_permissions())
      role3 = insert!(:role, permissions: random_role_permissions())
      role4 = insert!(:role, permissions: random_role_permissions())
      role5 = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.role_index_path(conn, :index))
      assert live |> element("a", role1.name) |> render() =~ Enum.join(role1.permissions, " / ")
      assert live |> element("a", role2.name) |> render() =~ Enum.join(role2.permissions, " / ")
      assert live |> element("a", role3.name) |> render() =~ Enum.join(role3.permissions, " / ")
      assert live |> element("a", role4.name) |> render() =~ Enum.join(role4.permissions, " / ")
      assert live |> element("a", role5.name) |> render() =~ "(This role has no permissions.)"
    end

    test "Show(:show) displays the role", %{conn: conn} do
      role = insert!(:role, permissions: random_role_permissions())
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :show, role))
      assert live |> has_element?("header span.text-xl", "Role")
      assert live |> has_element?("p.text-3xl.font-thin", role.name)

      for permission <- role.permissions do
        assert live |> has_element?("dd", permission)
      end
    end

    test "Show(:show) displays a description when the role has no permissions", %{conn: conn} do
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :show, role))
      assert live |> has_element?("p", "(This role has no permissions.)")
    end

    test "Show(:show) does not display the edit button", %{conn: conn} do
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :show, role))
      refute live |> has_element?("button.material-icons", "edit")
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :edit, role))
             |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))
    end

    test "Show(:new) redirects to Index(:index)", %{conn: conn} do
      assert live(conn, Routes.role_show_path(conn, :new))
             |> follow_redirect(conn, Routes.role_index_path(conn, :index))
    end
  end

  describe "with edit_roles permission :" do
    setup %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["edit_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.role_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) redirects to Page(:index)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :show, role))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:edit) validates the updates", %{conn: conn} do
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :edit, role))
      live |> form("#role-form", role: %{name: ""}) |> render_change()
      assert live |> has_element?("p", "can't be blank")
      live |> form("#role-form", role: %{name: unique_role_name()}) |> render_change()
      refute live |> has_element?("p", "can't be blank")
    end

    test "Show(:edit) updates the role", %{conn: conn} do
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :edit, role))
      name = unique_role_name()
      permissions = random_role_permissions()

      live
      |> form("#role-form", %{role: %{name: name, permissions: permissions}})
      |> render_submit()

      assert %{"info" => "The role was updated successfully."} =
               assert_redirect(live, Routes.page_path(conn, :index))

      assert %{name: ^name, permissions: ^permissions} = HybridBlog.Accounts.get_role!(role.id)
    end

    test "Show(:new) redirects to Index(:index)", %{conn: conn} do
      assert live(conn, Routes.role_show_path(conn, :new))
             |> follow_redirect(conn, Routes.role_index_path(conn, :index))
    end
  end

  describe "with list_roles and edit_roles permission :" do
    setup %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["list_roles", "edit_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Show(:show) displays the edit link", %{conn: conn} do
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :show, role))
      assert live |> element("header a.material-icons", "edit") |> render_click()
      assert_patch(live, Routes.role_show_path(conn, :edit, role))
    end
  end

  describe "with create_roles permission :" do
    setup %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["create_roles"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.role_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) redirects to Page(:index)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :show, role))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      role = insert!(:role)

      assert live(conn, Routes.role_show_path(conn, :edit, role))
             |> follow_redirect(conn, Routes.role_show_path(conn, :show, role))
    end

    test "Show(:new) creates a new role", %{conn: conn} do
      exists = HybridBlog.Accounts.list_roles()
      {:ok, live, _html} = live(conn, Routes.role_show_path(conn, :new))
      name = unique_role_name()
      permissions = random_role_permissions()

      assert live
             |> form("#role-form", %{role: %{name: name, permissions: permissions}})
             |> render_submit()

      assert %{"info" => "The role was created successfully."} =
               assert_redirect(live, Routes.page_path(conn, :index))

      assert [%{name: ^name, permissions: ^permissions}] =
               HybridBlog.Accounts.list_roles() -- exists
    end
  end
end
