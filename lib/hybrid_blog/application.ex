defmodule HybridBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HybridBlog.Repo,
      # Start the Telemetry supervisor
      HybridBlogWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HybridBlog.PubSub},
      # Start the Endpoint (http/https)
      HybridBlogWeb.Endpoint
      # Start a worker by calling: HybridBlog.Worker.start_link(arg)
      # {HybridBlog.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HybridBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HybridBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
