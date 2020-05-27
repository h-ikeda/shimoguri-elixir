defmodule Hodono.Repo do
  use Ecto.Repo,
    otp_app: :hodono,
    adapter: Ecto.Adapters.Postgres
end
