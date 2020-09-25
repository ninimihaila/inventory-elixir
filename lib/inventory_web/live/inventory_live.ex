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

    changeset = Items.change_item(%Item{})

    items =
      Items.list_items(
        sort: sort_options,
        filter: filter_options
      )

    socket =
      assign(socket,
        options: Map.merge(sort_options, filter_options),
        items: items,
        name: name,
        changeset: changeset
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <!-- TODO: action buttons -->
      <!-- TODO: edit -->
      <!-- TODO: filter(s) -->
      <!-- TODO: style -->
      <%= f = form_for @changeset, "#",
          phx_submit: "save" %>
        <div class="field">
          <%= label f, :name %>
          <%= text_input f, :name,
                          placeholder: "Name",
                          autocomplete: "off" %>
          <%= error_tag f, :name %>
        </div>

        <div class="field">
          <%= label f, :entry_date %>
          <%= date_input f, :entry_date %>
          <%= error_tag f, :entry_date %>
        </div>

        <div class="field">
          <%= label f, :expiry_date %>
          <%= date_input f, :expiry_date %>
          <%= error_tag f, :expiry_date %>
        </div>

        <%= submit "Add item", phx_disable_with: "Saving..." %>
      </form>


      <form phx-change="filter">
        <input type="text" name="name"
          value="<%= @name %>"
          autocomplete="false"
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
            <td><%= item.name %></td>
            <td><%= item.expiry_date %></td>
            <td>
              <button class="delete-btn"
                  phx-click="delete"
                  phx-value-id="<%= item.id %>"
                  phx-disable-with="Deleting...">
                Delete
              </button>
            </td>
          </tr>
        <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def handle_event("save", %{"item" => params}, socket) do
    case Items.create_item(params) do
      {:ok, _item} ->
        changeset = Items.change_item(%Item{})

        # TODO: this should be done with phx-prepend somehow
        items = Items.list_items(socket.assigns.options)

        socket = assign(socket, changeset: changeset, items: items)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
          socket = assign(socket, changeset: changeset)
          {:noreply, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Items.delete_item(Items.get_item!(id))

    {:noreply, redirect_with_attrs(socket)}
  end

  def handle_event("filter", %{"name" => name}, socket) do
    {:noreply, redirect_with_attrs(socket, name: name)}
  end

  defp redirect_with_attrs(socket, attrs \\ %{}) do
    name = attrs[:name] || socket.assigns.name
    sort_by = attrs[:sort_by] || socket.assigns.options.sort_by
    sort_order = attrs[:sort_order] || socket.assigns.options.sort_order

    push_patch(socket, to: Routes.live_path(socket, __MODULE__, name: name, sort_by: sort_by, sort_order: sort_order))
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
