defmodule GameWeb.Live.Components.LoadingSpinnerComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
      <span class="ml-3 text-lg text-green-600"><%= @text %></span>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, text: assigns[:text] || "Loading...")}
  end
end
