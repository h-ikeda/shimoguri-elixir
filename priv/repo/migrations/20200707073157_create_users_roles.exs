defmodule HybridBlog.Repo.Migrations.CreateUsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add :user_id, references(:users, type: :binary_id)
      add :role_id, references(:roles)
    end
  end
end
