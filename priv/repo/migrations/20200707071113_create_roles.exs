defmodule HybridBlog.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :binary
      add :permissions, {:array, :string}

      timestamps()
    end
  end
end
