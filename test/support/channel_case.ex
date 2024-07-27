defmodule GameWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import GameWeb.ChannelCase

      @endpoint GameWeb.Endpoint
    end
  end

  setup _tags do
    :ok
  end
end
