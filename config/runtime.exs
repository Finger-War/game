import Config

# Common configuration for all environments
secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    if config_env() == :prod do
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """
    else
      # Default keys for dev/test if not set via env var
      %{
        dev: "m12U/+mR5vxYKcHCg41rij08FTWiNtLqAPZs0XYxpJRo+ca/jhvZy9f29Q//NQ/r",
        test: "zbfG39uJK2UaB/EFEiyHx/7xWdEwfl63rsjnQv98umlAXjESFYizIbIZ09JGIEXx"
      }[config_env()]
    end

# Configure the endpoint with the secret key base
config :game, GameWeb.Endpoint, secret_key_base: secret_key_base

if System.get_env("PHX_SERVER") do
  config :game, GameWeb.Endpoint, server: true
end

if config_env() == :prod do
  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :game, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :game, GameWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ]
end
