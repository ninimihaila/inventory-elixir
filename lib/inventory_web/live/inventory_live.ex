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

  # def handle_info({:updated_item, item}, socket) do
  #   socket =
  #     socket
  #     |> update(:items, fn items -> [item | items] end)

  #   {:noreply, socket}
  # end

  # def handle_info({:deleted_item, item}, socket) do
  #   socket =
  #     socket
  #     |> update(:items, fn items -> [item | items] end)

  #   {:noreply, socket}
  # end

  def handle_event("save", %{"item" => params}, socket) do
    case Items.create_item(params) do
      {:ok, _item} ->
        changeset = Items.change_item(%Item{})

        # send(self(), {:updated_item, item})

        # socket = assign(socket, changeset: changeset)

        {:noreply, redirect_with_attrs(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
          socket = assign(socket, changeset: changeset)
          {:noreply, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Items.delete_item(Items.get_item!(id)) do
      {:ok, _item} ->
        # send(self(), {:deleted_item, item})

        {:noreply, redirect_with_attrs(socket)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
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

  # defp sort_header_link(text, s, %{"sort_by" => sort_by, "sort_order"=> sort_order}) when sort_by == s do
  #   "#{text} #{sort_arrow(sort_order)}"
  # end
  # defp sort_header_link(text, _, _), do: text

  # defp sort_arrow(:asc), do: "▲"
  # defp sort_arrow(:desc), do: "▼"

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
