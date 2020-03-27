# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :calculator,
  ecto_repos: [Calculator.Repo]

# Configures the endpoint
config :calculator, CalculatorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "r0S33nrl5yUzXe55GK3kN96dyFgMJqA1YJ3Ae7nv9z3DaJoyV1ycujkB3eM0PQFC",
  render_errors: [view: CalculatorWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Calculator.PubSub,
  live_view: [signing_salt: "V+qloEsk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
