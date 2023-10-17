defmodule AuctionWeb.SortOptionsComponent do
  use AuctionWeb, :live_component

  def render(assigns) do
    sorting_options = [
      "#{gettext("ID")}": "id",
      "#{gettext("Make")}": "make",
      "#{gettext("Year")}": "year"
    ]

    ~H"""
    <div class="sort-options">
      <form phx-change="sort-by" phx-target={@myself}>
        <label for="sort-by"><%= gettext("Sort by") %></label>
        <select name="sort-by">
          <%= Phoenix.HTML.Form.options_for_select(
            sorting_options,
            @options.sort_by
          ) %>
        </select>
      </form>
      <div class="sort-order">
        <button phx-click="sort-order" phx-target={@myself}>
          <%= sort_opt(assigns) %>
        </button>
      </div>
    </div>
    """
  end

  def handle_event("sort-by", %{"sort-by" => sort_by}, socket) do
    sort_by = String.downcase(sort_by)

    params = %{socket.assigns.options | sort_by: sort_by}
    send(self(), {:sort_option_changed, params})

    {:noreply, socket}
  end

  def handle_event("sort-order", _, socket) do
    params = %{
      socket.assigns.options
      | sort_order: next_sort_order(socket.assigns.options.sort_order)
    }

    IO.inspect(params, label: "params")
    send(self(), {:sort_order_changed, params})

    {:noreply, socket}
  end

  def sort_opt(assigns) do
    caret_or_v =
      if assigns.options.sort_order == :asc do
        "👆"
      else
        "👇"
      end
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end
end
