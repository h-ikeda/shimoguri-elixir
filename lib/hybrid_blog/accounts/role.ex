defmodule HybridBlog.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :binary
    field :permissions, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :permissions])
    |> validate_required([:name, :permissions])
    |> validate_subset(:permissions, permissions())
  end

  def permissions do
    [
      "list_users",
      "edit_users",
      "edit_user_roles",
      "delete_users",
      "list_roles",
      "create_roles",
      "edit_roles",
      "delete_roles"
    ]
  end
end
