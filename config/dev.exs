import Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :game, GameWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: port],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "m12U/+mR5vxYKcHCg41rij08FTWiNtLqAPZs0XYxpJRo+ca/jhvZy9f29Q//NQ/r",
  watchers: []

config :game, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false
