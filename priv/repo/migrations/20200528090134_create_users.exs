defmodule HybridBlog.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :binary
      add :picture, :binary

      timestamps()
    end
  end
end
