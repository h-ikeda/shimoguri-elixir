defmodule HybridBlog.Repo do
  use Ecto.Repo,
    otp_app: :hybrid_blog,
    adapter: Ecto.Adapters.Postgres
end
