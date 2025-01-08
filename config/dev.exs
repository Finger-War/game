import Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :game, GameWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: port],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "m12U/+mR5vxYKcHCg41rij08FTWiNtLqAPZs0XYxpJRo+ca/jhvZy9f29Q//NQ/r",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:game, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:game, ~w(--watch)]}
  ]

config :game, GameWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/game_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :game, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
