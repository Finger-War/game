defmodule GameWeb.Live.Components.NodeStatusComponent do
  use Phoenix.LiveComponent
  require Logger

  def render(assigns) do
    ~H"""
    <div class="bg-gray-900 bg-opacity-50 rounded-lg border border-indigo-800 overflow-hidden">
      <div class="p-3 bg-gray-800 border-b border-indigo-900 flex items-center">
        <i class="fas fa-network-wired text-blue-400 mr-2"></i>
        <h3 class="font-bold text-blue-300">Cluster Status</h3>
      </div>

      <div class="p-4 text-sm">
        <div class="flex flex-wrap gap-2">
          <!-- Current Node -->
          <div class="bg-green-900 bg-opacity-50 rounded px-3 py-1.5 border border-green-800 flex items-center">
            <div class="h-2 w-2 rounded-full bg-green-400 mr-2 animate-pulse"></div>
            <div>
              <div class="text-xs text-green-400">CURRENT NODE</div>
              <div class="font-mono text-white"><%= @current_node %></div>
            </div>
          </div>

          <!-- Connected Nodes -->
          <%= for node <- @connected_nodes do %>
            <div class="bg-blue-900 bg-opacity-50 rounded px-3 py-1.5 border border-blue-800">
              <div class="text-xs text-blue-400">CONNECTED</div>
              <div class="font-mono text-white"><%= node %></div>
            </div>
          <% end %>

          <%= if Enum.empty?(@connected_nodes) do %>
            <div class="bg-gray-800 bg-opacity-50 rounded px-3 py-1.5 border border-gray-700">
              <div class="text-xs text-gray-400">NO CONNECTED NODES</div>
              <div class="text-gray-300">Running in standalone mode</div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def update(_assigns, socket) do
    {:ok,
     assign(socket,
       current_node: Node.self(),
       connected_nodes: Node.list()
     )}
  end
end
