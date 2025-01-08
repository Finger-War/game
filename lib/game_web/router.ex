defmodule GameWeb.Router do
  use GameWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GameWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GameWeb do
    pipe_through :browser

    live "/", PageLive, :home
    live "/match", MatchLive, :match
  end

  if Application.compile_env(:game, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GameWeb.Telemetry
    end
  end
end
