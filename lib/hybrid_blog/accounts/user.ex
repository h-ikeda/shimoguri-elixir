defmodule HybridBlog.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :binary
    field :picture, :binary
    field :google_sub, :binary
    field :role_ids, {:array, :integer}, virtual: true

    timestamps()

    many_to_many :roles, HybridBlog.Accounts.Role,
      join_through: "users_roles",
      on_replace: :delete
  end

  @doc false
  def changeset(user, attrs, rscs \\ %{}) do
    user
    |> cast(attrs, [:name, :picture, :role_ids])
    |> validate_required([:name, :picture])
    |> validate_role_ids(rscs)
    |> put_roles(rscs)
  end

  defp validate_role_ids(user, %{roles: roles}) do
    validate_subset(user, :role_ids, Enum.map(roles, & &1.id))
  end

  defp validate_role_ids(user, _) do
    validate_change(user, :role_ids, fn :role_ids, _ -> [role_ids: "can't list roles"] end)
  end

  defp put_roles(user, %{roles: roles}) do
    case fetch_change(user, :role_ids) do
      {:ok, role_ids} -> put_assoc(user, :roles, Enum.filter(roles, &(&1.id in role_ids)))
      :error -> user
    end
  end

  defp put_roles(user, _), do: user
end
