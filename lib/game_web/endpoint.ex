defmodule GameWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :game

  @session_options [
    store: :cookie,
    key: "_game_key",
    signing_salt: "2dmM5ddF",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  socket "/socket", GameWeb.PlayerSocket,
    websocket: true,
    longpoll: false

  plug Plug.Static,
    at: "/",
    from: :game,
    gzip: false,
    only: GameWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug GameWeb.Router
end
