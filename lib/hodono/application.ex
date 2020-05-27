defmodule Hodono.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Hodono.Repo,
      # Start the Telemetry supervisor
      HodonoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hodono.PubSub},
      # Start the Endpoint (http/https)
      HodonoWeb.Endpoint
      # Start a worker by calling: Hodono.Worker.start_link(arg)
      # {Hodono.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hodono.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HodonoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
