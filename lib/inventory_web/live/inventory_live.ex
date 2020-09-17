defmodule InventoryWeb.InventoryLive do
  use InventoryWeb, :live_view

  alias Inventory.Items
  alias Inventory.Items.Item

  def mount(_params, _session, socket) do
    socket = assign(socket, items: Items.list_items())
    {:ok, socket, temporary_assigns: [items: []]}
  end

  def render(assigns) do
    ~L"""
    <div>
      <!-- TODO: add form to add item -->
      <!-- TODO: search -->
      <!-- TODO: highlight expired/soon -->
      <!-- TODO: sort, filter -->
      <%= for item <- @items do %>
        <p><%= item.name %> <%= item.expiry_date %></p>
      <% end %>
    </div>
    """
  end
end
