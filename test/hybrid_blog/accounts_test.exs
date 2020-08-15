defmodule HybridBlog.AccountsTest do
  use HybridBlog.DataCase
  import HybridBlog.Factory

  alias HybridBlog.Accounts
  alias HybridBlog.Accounts.User
  alias HybridBlog.Accounts.Role

  describe "users" do
    test "list_users/0 returns all users" do
      user1 = insert!(:user, roles: [])
      user2 = insert!(:user, roles: [])
      assert Accounts.list_users() == [user1, user2]
    end

    test "list_users/0 preloads all user's roles" do
      role1 = build(:role)
      role2 = build(:role)
      role3 = build(:role)
      insert!(:user, roles: [role1])
      insert!(:user, roles: [role2, role3])
      assert [%{roles: [role1]}, %{roles: [role2, role3]}] = Accounts.list_users()
    end

    test "get_user!/1 returns the user with given id" do
      insert!(:user)
      insert!(:user)
      user = insert!(:user)
      insert!(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/2 with google_sub creates a user without roles" do
      name = unique_user_name()
      picture = unique_user_picture()
      google_sub = unique_user_google_sub()

      assert {:ok, %User{} = user} =
               Accounts.create_user(%{name: name, picture: picture}, google_sub: google_sub)

      assert user.name == name
      assert user.picture == picture
      assert user.google_sub == google_sub
      assert %{roles: []} = HybridBlog.Repo.preload(user, :roles)
    end

    test "create_user/2 with google_sub without name returns error changeset" do
      picture = unique_user_picture()
      google_sub = unique_user_google_sub()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{picture: picture}, google_sub: google_sub)
    end

    test "create_user/2 with google_sub without picture returns error changeset" do
      name = unique_user_name()
      google_sub = unique_user_google_sub()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{name: name}, google_sub: google_sub)
    end

    test "create_user/2 with google_sub with empty name returns error changeset" do
      picture = unique_user_picture()
      google_sub = unique_user_google_sub()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{name: "", picture: picture}, google_sub: google_sub)
    end

    test "create_user/2 with google_sub with empty picture returns error changeset" do
      name = unique_user_name()
      google_sub = unique_user_google_sub()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{name: name, picture: ""}, google_sub: google_sub)
    end

    test "update_user/2 updates the user" do
      user = insert!(:user)
      name = unique_user_name()
      picture = unique_user_picture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{name: name, picture: picture})
      assert user.name == name
      assert user.picture == picture
    end

    test "update_user/2 with empty name returns error changeset" do
      user = insert!(:user)
      picture = unique_user_picture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, %{name: "", picture: picture})

      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 with empty picture returns error changeset" do
      user = insert!(:user)
      name = unique_user_name()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{name: name, picture: ""})
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/3 with role_ids and role resources updates the user roles" do
      role1 = insert!(:role)
      role2 = insert!(:role)
      user = insert!(:user, roles: [])

      assert {:ok, %User{} = user} =
               Accounts.update_user(user, %{role_ids: [role1.id]}, %{roles: [role1, role2]})

      assert user.roles == [role1]
    end

    test "update_user/3 with role_ids without role resources returns an error changeset" do
      user = insert!(:user, roles: [])
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{role_ids: [1]}, %{})
    end

    test "delete_user/1 deletes the user" do
      user = insert!(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = build(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "permissions/1 returns a MapSet of permissions" do
      permissions1 = random_role_permissions()
      permissions2 = random_role_permissions()
      role1 = build(:role, permissions: permissions1)
      role2 = build(:role, permissions: permissions2)
      user = build(:user, roles: [role1, role2])
      assert Accounts.permissions(user) == MapSet.new(permissions1 ++ permissions2)
    end

    test "permissions/1 returns an empty MapSet when the user has no roles" do
      user = build(:user, roles: [])
      assert Accounts.permissions(user) == MapSet.new()
    end

    test "permissions/1 returns an empty MapSet when the user roles have no permissions" do
      user = build(:user, roles: [build(:role, permissions: nil), build(:role, permissions: [])])
      assert Accounts.permissions(user) == MapSet.new()
    end
  end

  describe "roles" do
    test "list_roles/0 returns all roles" do
      role1 = insert!(:role)
      role2 = insert!(:role)
      role3 = insert!(:role)
      assert Accounts.list_roles() == [role1, role2, role3]
    end

    test "get_role!/1 returns the role with given id" do
      insert!(:role)
      role = insert!(:role)
      insert!(:role)
      insert!(:role)
      assert Accounts.get_role!(role.id) == role
    end

    test "get_roles/1 returns the roles specified by IDs" do
      role1 = insert!(:role)
      insert!(:role)
      insert!(:role)
      role2 = insert!(:role)
      role3 = insert!(:role)
      insert!(:role)
      assert Accounts.get_roles([role1.id, role2.id, role3.id]) == [role1, role2, role3]
    end

    test "create_role/1 creates a role" do
      name = unique_role_name()
      permissions = random_role_permissions()
      assert {:ok, %Role{} = role} = Accounts.create_role(%{name: name, permissions: permissions})
      assert role.name == name
      assert role.permissions == permissions
    end

    test "create_role/1 creates a role with empty permissions" do
      name = unique_role_name()
      assert {:ok, %Role{} = role} = Accounts.create_role(%{name: name, permissions: []})
      assert role.name == name
      assert role.permissions == []
    end

    test "create_role/1 creates a role without permissions" do
      name = unique_role_name()
      assert {:ok, %Role{} = role} = Accounts.create_role(%{name: name})
      assert role.name == name
    end

    test "create_role/1 with duplicated permissions deduplicates permissions" do
      name = unique_role_name()
      permissions = random_role_permissions()
      duplicated = permissions |> List.duplicate(2) |> List.flatten()
      assert {:ok, %Role{} = role} = Accounts.create_role(%{name: name, permissions: duplicated})
      assert role.permissions == permissions
    end

    test "create_role/1 with empty name returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_role(%{name: "", permissions: random_role_permissions()})
    end

    test "create_role/1 with invalid permissions returns error changeset" do
      name = unique_role_name()
      permissions = ["invalid_permission" | random_role_permissions()]

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_role(%{name: name, permissions: permissions})
    end

    test "update_role/2 updates the role" do
      role = insert!(:role)
      name = unique_role_name()
      permissions = random_role_permissions()

      assert {:ok, %Role{} = role} =
               Accounts.update_role(role, %{name: name, permissions: permissions})

      assert role.name == name
      assert role.permissions == permissions
    end

    test "update_role/2 with empty name returns error changeset" do
      role = insert!(:role)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_role(role, %{name: "", permissions: random_role_permissions()})

      assert role == Accounts.get_role!(role.id)
    end

    test "update_role/2 with invalid permissions returns error changeset" do
      role = insert!(:role)
      name = unique_role_name()
      permissions = ["invalid_permission" | random_role_permissions()]

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_role(role, %{name: name, permissions: permissions})

      assert role == Accounts.get_role!(role.id)
    end

    test "update_role/2 with duplicated permissions deduplicates permissions" do
      role = insert!(:role)
      name = unique_role_name()
      permissions = random_role_permissions()
      duplicated = permissions |> List.duplicate(2) |> List.flatten()

      assert {:ok, %Role{} = role} =
               Accounts.update_role(role, %{name: name, permissions: duplicated})

      assert role.permissions == permissions
    end

    test "delete_role/1 deletes the role" do
      role = insert!(:role)
      assert {:ok, %Role{}} = Accounts.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = build(:role)
      assert %Ecto.Changeset{} = Accounts.change_role(role)
    end
  end
end
