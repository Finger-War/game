defmodule GameWeb.PageController do
  use GameWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
