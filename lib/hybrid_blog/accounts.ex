defmodule HybridBlog.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias HybridBlog.Repo
  alias __MODULE__.User
  alias __MODULE__.Role
  @type user :: %User{}
  @type role :: %Role{}
  @doc """
  Returns the list of users.
  """
  @spec list_users() :: [user]
  def list_users, do: Repo.all(from User, preload: :roles)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  @spec get_user!(Ecto.UUID.t()) :: user
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user with preloading the :roles associations.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  @spec get_user_with_roles!(Ecto.UUID.t()) :: user
  def get_user_with_roles!(id), do: Repo.get!(User |> preload(:roles), id)

  @doc """
  Creates an user.

  An user subject from auth providers must be given.
  """
  @spec create_user(map, keyword) :: {:ok, user} | {:error, Ecto.Changeset.t(user)}
  def create_user(attrs, google_sub: google_sub) do
    %User{google_sub: google_sub} |> User.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Updates an user.

  The `rscs` is a map of resources used to get associations from given ID fields.
  """
  @spec update_user(user, map, map) :: {:ok, user} | {:error, Ecto.Changeset.t(user)}
  def update_user(%User{} = user, attrs, rscs \\ %{}) do
    user |> User.changeset(attrs, rscs) |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  @spec delete_user(user) :: {:ok, user} | {:error, Ecto.Changeset.t(user)}
  def delete_user(%User{} = user), do: Repo.delete(user)

  @doc """
  Returns an `t:Ecto.Changeset/0` for tracking user changes.
  """
  @spec change_user(user, map, map) :: Ecto.Changeset.t(user)
  def change_user(%User{} = user, attrs \\ %{}, rscs \\ %{}) do
    User.changeset(user, attrs, rscs)
  end

  @doc """
  Gets a single user by a specific field.

  Return `nil` if the User does not exist.
  """
  @spec get_user_by(atom, any) :: user | nil
  def get_user_by(field, value) when is_atom(field), do: Repo.get_by(User, [{field, value}])

  @doc """
  Gets the user having permissions set.
  """
  @spec permissions(user) :: MapSet.t(binary)
  def permissions(%User{roles: []}), do: MapSet.new()

  def permissions(%User{roles: roles}) do
    roles |> Enum.map(&MapSet.new(&1.permissions || [])) |> Enum.reduce(&MapSet.union/2)
  end

  @doc """
  Returns the list of roles.
  """
  @spec list_roles() :: [role]
  def list_roles, do: Repo.all(Role)

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.
  """
  @spec get_role!(integer) :: role
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Gets the list of roles specified by IDs.
  """
  @spec get_roles([integer]) :: [role]
  def get_roles(ids), do: Repo.all(from role in Role, where: role.id in ^ids)

  @doc """
  Creates a role.
  """
  @spec create_role(map) :: {:ok, role} | {:error, Ecto.Changeset.t(role)}
  def create_role(attrs \\ %{}), do: %Role{} |> Role.changeset(attrs) |> Repo.insert()

  @doc """
  Updates a role.
  """
  @spec update_role(role, map) :: {:ok, role} | {:error, Ecto.Changeset.t(role)}
  def update_role(%Role{} = role, attrs), do: role |> Role.changeset(attrs) |> Repo.update()

  @doc """
  Deletes a role.
  """
  @spec delete_role(role) :: {:ok, role} | {:error, Ecto.Changeset.t(role)}
  def delete_role(%Role{} = role), do: Repo.delete(role)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.
  """
  @spec change_role(role, map) :: Ecto.Changeset.t(role)
  def change_role(%Role{} = role, attrs \\ %{}), do: Role.changeset(role, attrs)
end
