defmodule HybridBlog.Release do
  @app :hybrid_blog
  def migrate(_argv) do
    {:ok, _} = Application.ensure_all_started(:ssl)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(argv) do
    {:ok, _} = Application.ensure_all_started(:ssl)
    {options, _, _} = OptionParser.parse(argv, strict: [repo: :string, version: :integer])
    repo = Module.concat(Macro.camelize(@sapp), Keyword.fetch!(options, :repo))
    version = Keyword.fetch!(options, :version)
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end
end
