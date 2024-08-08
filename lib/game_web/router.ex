defmodule GameWeb.Router do
  use GameWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GameWeb do
    pipe_through :api
  end

  if Application.compile_env(:game, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: GameWeb.Telemetry
    end
  end
end
