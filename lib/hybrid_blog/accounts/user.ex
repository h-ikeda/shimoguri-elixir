defmodule HybridBlog.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :binary
    field :picture, :binary
    field :google_sub, :binary

    timestamps()

    many_to_many :roles, HybridBlog.Accounts.Role,
      join_through: "users_roles",
      on_replace: :delete
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :picture])
    |> validate_required([:name, :picture])
    |> put_roles(attrs)
  end

  defp put_roles(user, %{roles: roles}) when is_list(roles), do: put_assoc(user, :roles, roles)
  defp put_roles(user, %{"roles" => roles}), do: put_roles(user, %{roles: roles})
  defp put_roles(user, _), do: user
end
