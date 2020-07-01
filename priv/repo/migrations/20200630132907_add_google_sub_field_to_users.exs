defmodule HybridBlog.Repo.Migrations.AddGoogleSubFieldToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :google_sub, :binary
    end
  end
end
