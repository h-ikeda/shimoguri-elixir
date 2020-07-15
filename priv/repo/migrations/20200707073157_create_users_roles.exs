defmodule HybridBlog.Repo.Migrations.CreateUsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :role_id, references(:roles, on_delete: :delete_all)
    end
  end
end
