defmodule HybridBlogWeb.UserLiveTest do
  use HybridBlogWeb.ConnCase
  import HybridBlog.Factory
  import Phoenix.LiveViewTest

  describe "without authentication :" do
    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.user_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) displays the user without roles", %{conn: conn} do
      user = insert!(:user, roles: [build(:role)])
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?("img[src=\"#{user.picture}\"]")
      assert live |> has_element?("span", user.name)
      refute live |> has_element?("dl dt", "Roles")
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      user = insert!(:user)

      assert live(conn, Routes.user_show_path(conn, :edit, user))
             |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))
    end
  end

  describe "without permissions :" do
    setup %{conn: conn} do
      user = insert!(:user)
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn, user: user}
    end

    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.user_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) displays the user without roles", %{conn: conn} do
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?("img[src=\"#{user.picture}\"]")
      assert live |> has_element?("span", user.name)
      refute live |> has_element?("dl dt", "Roles")
    end

    test "Show(:show) displays the current user", %{conn: conn, user: user} do
      assert {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?("img[src=\"#{user.picture}\"]")
      assert live |> has_element?("span", user.name)
      assert live |> has_element?("dl dt", "Roles")
    end

    test "Show(:show) does not display the edit button", %{conn: conn} do
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      refute live |> has_element?("a.material-icons", "edit")
    end

    test "Show(:show) displays the edit button for the current user", %{conn: conn, user: user} do
      assert {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      live |> element("a.material-icons", "edit") |> render_click()
      assert_patch(live, Routes.user_show_path(conn, :edit, user))
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      user = insert!(:user)

      assert live(conn, Routes.user_show_path(conn, :edit, user))
             |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))
    end

    test "Show(:edit) updates the current user", %{conn: conn, user: user} do
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))
      user_params = %{name: unique_user_name(), picture: unique_user_picture()}
      live |> form("#user-form", %{user: user_params}) |> render_submit()
      assert_patch(live, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?(".text-2xl", user_params.name)
      assert live |> has_element?("img[src=\"#{user_params.picture}\"]")
    end

    test "Show(:edit) rejects to update the current user roles", %{conn: conn, user: user} do
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))
      refute live |> has_element?("#user_role_ids")

      user_params = %{
        name: unique_user_name(),
        picture: unique_user_picture(),
        role_ids: [role.id]
      }

      live |> element("#user-form") |> render_submit(%{user: user_params})
      assert live |> has_element?("#user-form")
      assert live |> has_element?("p", "can't list roles")
    end

    test "Show(:edit) validates the current user updates", %{conn: conn, user: user} do
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))
      live |> form("#user-form", %{user: %{name: ""}}) |> render_change()
      assert live |> has_element?("p", "can't be blank")
      live |> form("#user-form", %{user: %{name: "some"}}) |> render_change()
      refute live |> has_element?("p", "can't be blank")
      live |> form("#user-form", %{user: %{picture: ""}}) |> render_change()
      assert live |> has_element?("p", "can't be blank")
      live |> form("#user-form", %{user: %{picture: "some"}}) |> render_change()
      refute live |> has_element?("p", "can't be blank")
    end
  end

  describe "with list_users permission :" do
    setup %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["list_users"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Index(:index) lists all users", %{conn: conn} do
      user1 = insert!(:user)
      user2 = insert!(:user)
      user3 = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert live |> element("main a", user1.name) |> render() =~ user1.picture
      assert live |> element("main a", user2.name) |> render() =~ user2.picture
      assert live |> element("main a", user3.name) |> render() =~ user3.picture
    end

    test "Index(:index) displays links to users", %{conn: conn} do
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_index_path(conn, :index))
      assert live |> element("main a", user.name) |> render_click()
      assert_patch(live, Routes.user_show_path(conn, :show, user))
    end

    test "Show(:edit) redirects to Show(:show)", %{conn: conn} do
      user = insert!(:user)

      assert live(conn, Routes.user_show_path(conn, :edit, user))
             |> follow_redirect(conn, Routes.user_show_path(conn, :show, user))
    end
  end

  describe "with edit_users permission :" do
    setup %{conn: conn} do
      user = insert!(:user, roles: [build(:role, permissions: ["edit_users"])])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Index(:index) redirects to Page(:index)", %{conn: conn} do
      assert live(conn, Routes.user_index_path(conn, :index))
             |> follow_redirect(conn, Routes.page_path(conn, :index))
    end

    test "Show(:show) displays the user", %{conn: conn} do
      user = insert!(:user)
      assert {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?("img[src=\"#{user.picture}\"]")
      assert live |> has_element?("span", user.name)
      assert live |> has_element?("dl dt", "Roles")
    end

    test "Show(:show) displays the link to Show(:edit)", %{conn: conn} do
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?("a.material-icons", "edit")
    end

    test "Show(:edit) validates the updates", %{conn: conn} do
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))
      live |> form("#user-form", user: %{name: ""}) |> render_change()
      assert live |> has_element?("p", "can't be blank")
      live |> form("#user-form", user: %{name: unique_user_name()}) |> render_change()
      refute live |> has_element?("p", "can't be blank")
      live |> form("#user-form", user: %{picture: ""}) |> render_change()
      assert live |> has_element?("p", "can't be blank")
      live |> form("#user-form", user: %{picture: unique_user_picture()}) |> render_change()
      refute live |> has_element?("p", "can't be blank")
    end

    test "Show(:edit) updates the user", %{conn: conn} do
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))
      user_params = %{name: unique_user_name(), picture: unique_user_picture()}
      live |> form("#user-form", user: user_params) |> render_submit()
      assert_patch(live, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?("p", "User updated successfully")
      assert live |> has_element?(".text-2xl", user_params.name)
      assert live |> has_element?("img[src=\"#{user_params.picture}\"]")
    end

    test "Show(:edit) rejects to update the user roles", %{conn: conn} do
      role = insert!(:role)
      user = insert!(:user)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))
      refute live |> has_element?("#user_role_ids")

      user_params = %{
        name: unique_user_name(),
        picture: unique_user_picture(),
        role_ids: [role.id]
      }

      live |> element("#user-form") |> render_submit(%{user: user_params})
      assert live |> has_element?("#user-form")
      assert live |> has_element?("p", "can't list roles")
    end
  end

  describe "with edit_users and edit_user_roles permission :" do
    setup %{conn: conn} do
      permissions = ["edit_users", "edit_user_roles"]
      user = insert!(:user, roles: [build(:role, permissions: permissions)])
      conn = init_test_session(conn, %{current_user_id: user.id})
      %{conn: conn}
    end

    test "Show(:edit) updates the user", %{conn: conn} do
      user = insert!(:user)
      role = insert!(:role)
      {:ok, live, _html} = live(conn, Routes.user_show_path(conn, :edit, user))

      user_params = %{
        name: unique_user_name(),
        picture: unique_user_picture(),
        role_ids: [role.id]
      }

      live |> form("#user-form", %{user: user_params}) |> render_submit()
      assert_patch(live, Routes.user_show_path(conn, :show, user))
      assert live |> has_element?(".text-2xl", user_params.name)
      assert live |> has_element?("img[src=\"#{user_params.picture}\"]")
      assert live |> has_element?("dd", role.name)
    end
  end
end
