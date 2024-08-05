import Config

config :game,
  generators: [timestamp_type: :utc_datetime]

config :libcluster,
  topologies: [
    Dynamic_Game: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        port: 45892,
        multicast_addr: "255.255.255.255",
        multicast_ttl: 1,
        if_addr: {0, 0, 0, 0},
        ifaces: :default
      ]
    ]
  ]

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
