# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hybrid_blog,
  ecto_repos: [HybridBlog.Repo]

# Configures the endpoint
config :hybrid_blog, HybridBlogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KHLHTdPNoENq3XAQ3tb+5zSUekqHikHqVBiaxoJBDpzHZwssOai23ytcYIRuELf1",
  render_errors: [view: HybridBlogWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HybridBlog.PubSub,
  live_view: [signing_salt: "9qw4nku9"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

locales = ["en", "ja"]
config :hybrid_blog, HybridBlogWeb.Cldr, locales: locales, gettext: HybridBlogWeb.Gettext
config :hybrid_blog, HybridBlogWeb.Gettext, locales: locales

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :hybrid_blog, :title, "Hodono Tiny Developers"
