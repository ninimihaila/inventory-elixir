defmodule InventoryWeb.InventoryLive do
  use InventoryWeb, :live_view

  alias Inventory.Items
  alias Inventory.Items.Item

  def mount(_params, _session, socket) do
    socket = assign(socket, items: Items.list_items())

    {:ok, socket, temporary_assigns: [items: []]}
  end

  def handle_params(params, _url, socket) do
    sort_by = (params["sort_by"] || "expiry_date") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom()
    name = params["name"] || ""

    sort_options = %{sort_by: sort_by, sort_order: sort_order}
    filter_options = %{name: name}

    items =
      Items.list_items(
        sort: sort_options,
        filter: filter_options
      )

    socket =
      assign(socket,
        options: Map.merge(sort_options, filter_options),
        items: items,
        name: name
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <!-- TODO: add form to add item -->
      <!-- TODO: filter(s) -->
      <form phx-change="filter">
        <input type="text" name="name"
          value="<%= @name %>"
          placeholder="Search" autofocus
          />
      </form>

      <table>
        <thead>
          <tr>
            <th><%= sort_link(@socket, "Item", :name, @options) %></th>
            <th><%= sort_link(@socket, "Expires", :expiry_date, @options) %></th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
        <%= for item <- @items do %>
          <tr class="<%= item_class(item)%>">
            <td><%= item.name %></td><td><%= item.expiry_date %></td><td></td>
          </tr>
        <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def handle_event("filter", %{"name" => name}, socket) do
    socket = push_patch(socket,
      to: Routes.live_path(
        socket,
        __MODULE__,
        name: name,
        sort_by: socket.assigns.options.sort_by,
        sort_order: socket.assigns.options.sort_order
      )
    )

    {:noreply, socket}
  end

  def sort_link(socket, text, sort_by, options) do
    live_patch(text,
      to: Routes.live_path(
        socket,
        __MODULE__,
        name: options.name,
        sort_by: sort_by,
        sort_order: toggle_sort_order(options.sort_order)
      )
    )
  end

  defp item_class(item) do
    cond do
      Items.is_expired(item) -> "expired"

      Items.expires_soon?(item) -> "expires-soon"

      true -> ""
    end
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc
end
