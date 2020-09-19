# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :inventory,
  ecto_repos: [Inventory.Repo]

# Configures the endpoint
config :inventory, InventoryWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sE8h+oFvmKhXtN+pafU6j9STEUwcED6iWPsOMbnlTXjS8jRnxuO6bLtzWQEEYRAm",
  render_errors: [view: InventoryWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Inventory.PubSub,
  live_view: [signing_salt: "vPHHMSIV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
