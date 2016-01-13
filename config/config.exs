use Mix.Config

# Configures the endpoint
config :footy, Footy.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "fmJKqd3ZsIdqAghT3s+dGJCaofe7ywM4ll74U850vMXGTiyOcxxFytEp6ALpcdRH",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Footy.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
