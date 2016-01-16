use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :footy, Footy.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [],
  secret_key_base: "02d407f7ccc79be55a49ae8a2f25b1f4869c8d89a91e0b844f2a3ae7c83c616f549883f218f81c084483ad7d9590905a6edd89810717d716a5cbefe1ecf44e82"

# Watch static and templates for browser reloading.
config :footy, Footy.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

config :phoenix, Footy.Router,
  session: [store: :cookie,
            key: "sharkeyfootytipping"]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20
