import Config

config :game,
  generators: [timestamp_type: :utc_datetime]

config :game, GameWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: GameWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Game.PubSub,
  live_view: [signing_salt: "9QIndD7D"]

config :game, Game.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
