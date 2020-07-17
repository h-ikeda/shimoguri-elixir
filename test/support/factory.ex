defmodule HybridBlog.Factory do
  alias HybridBlog.Repo
  alias HybridBlog.Accounts.User
  alias HybridBlog.Accounts.Role

  def build(:user) do
    %User{
      name: unique_user_name(),
      picture: unique_user_picture(),
      google_sub: unique_user_google_sub()
    }
  end

  def build(:role), do: %Role{name: unique_role_name()}
  def build(factory, attrs), do: build(factory) |> struct!(attrs)
  def insert!(factory, attrs \\ []), do: build(factory, attrs) |> Repo.insert!()

  def unique_user_name, do: "user name #{System.unique_integer([:positive])}"

  def unique_user_picture do
    "https://example.com/user-picture-#{System.unique_integer([:positive])}"
  end

  def unique_user_google_sub do
    System.unique_integer([:positive])
    |> Integer.to_string()
    |> String.pad_leading(11, "0")
  end

  def unique_role_name, do: "role name #{System.unique_integer([:positive])}"
  def random_role_permissions, do: Enum.take_random(Role.permissions(), :rand.uniform(7))
end
