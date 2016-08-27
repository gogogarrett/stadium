# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :stadium_web,
  ecto_repos: [StadiumWeb.Repo]

# Configures the endpoint
config :stadium_web, StadiumWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bfQBsO2iJZMf4IVZr6dQgGTHhstRbHtGzPUhxL6p1GEDXv4Dvrwk6e9JI4RiCZjS",
  render_errors: [view: StadiumWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: StadiumWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
