defmodule HybridBlog.AccountsTest do
  use HybridBlog.DataCase

  alias HybridBlog.Accounts

  describe "users" do
    alias HybridBlog.Accounts.User

    @valid_attrs %{name: "some name", picture: "some picture"}
    @update_attrs %{name: "some updated name", picture: "some updated picture"}
    @invalid_attrs %{name: nil, picture: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture() |> Repo.preload([:roles])
      assert Accounts.list_users() == [user]
    end

    test "list_users/0 preloads all user's roles" do
      _ = user_fixture()
      assert List.first(Accounts.list_users()).roles == []
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "some name"
      assert user.picture == "some picture"
    end

    test "create_user/1 with google_sub creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs, google_sub: "01234567890")
      assert user.name == "some name"
      assert user.picture == "some picture"
      assert user.google_sub == "01234567890"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.name == "some updated name"
      assert user.picture == "some updated picture"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 with roles association updates the user roles" do
      user = user_fixture() |> Repo.preload(:roles)
      role = role_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{"roles" => [role.id]})
      assert user.roles == [role]
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "roles" do
    alias HybridBlog.Accounts.Role

    @valid_attrs %{name: "some name", permissions: []}
    @update_attrs %{name: "some updated name", permissions: []}
    @invalid_attrs %{name: nil, permissions: nil}

    def role_fixture(attrs \\ %{}) do
      {:ok, role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_role()

      role
    end

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Accounts.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Accounts.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      assert {:ok, %Role{} = role} = Accounts.create_role(@valid_attrs)
      assert role.name == "some name"
      assert role.permissions == []
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      assert {:ok, %Role{} = role} = Accounts.update_role(role, @update_attrs)
      assert role.name == "some updated name"
      assert role.permissions == []
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_role(role, @invalid_attrs)
      assert role == Accounts.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Accounts.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_role(role)
    end
  end
end
