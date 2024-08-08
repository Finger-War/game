import Config

config :game, GameWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zbfG39uJK2UaB/EFEiyHx/7xWdEwfl63rsjnQv98umlAXjESFYizIbIZ09JGIEXx",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
