defmodule HybridBlog.Release do
  @app :hybrid_blog
  def migrate(_argv) do
    start_apps()

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          cond do
            repo.__adapter__.storage_up(repo.config) in [:ok, {:error, :already_up}] ->
              Ecto.Migrator.run(repo, :up, all: true)
          end
        end)
    end
  end

  def rollback(argv) do
    start_apps()
    {options, _, _} = OptionParser.parse(argv, strict: [repo: :string, version: :integer])
    repo = Keyword.fetch!(options, :repo)
    version = Keyword.fetch!(options, :version)
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp start_apps do
    Application.load(@app)
    Application.ensure_started(:ssl)
  end
end
