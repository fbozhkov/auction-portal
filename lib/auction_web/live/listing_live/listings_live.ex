defmodule AuctionWeb.ListingsLive do
  use AuctionWeb, :live_view

  alias AuctionWeb.ListingCardComponent
  alias Auction.Listings

  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   :timer.send_interval(1000, self(), :tick)
    # end

    # socket = assign(socket, :time_left, nil)

    {:ok, assign(socket, :listings, [])}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)
    per_page = param_to_integer(params["per_page"], 8)
    page = param_to_integer(params["page"], 1)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      per_page: per_page,
      page: page
    }

    listings = Listings.list_listings(options)

    socket =
      assign(socket,
        listings: listings,
        options: options,
        listings_count: Listings.listing_count(),
        more_pages?: more_pages?(options, Listings.listing_count()),
        pages: pages(options, Listings.listing_count())
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="listings">
      <h3>All Listings</h3>
      <div class="sort-filter">
        <form phx-change="select-per-page">
          <select name="per-page">
            <%= Phoenix.HTML.Form.options_for_select(
              [8, 12, 16, 20],
              @options.per_page
            ) %>
          </select>
          <label for="per-page">per page</label>
        </form>
        <div class="sort-options">
          <form phx-change="sort-by">
            <label for="sort-by">Sort by</label>
            <select name="sort-by">
              <%= Phoenix.HTML.Form.options_for_select(
                ["id", "make", "year"],
                @options.sort_by
              ) %>
            </select>
          </form>
          <div class="sort-order">
            <.sort_link
              options={@options}>
              <%= @options.sort_order %>
            </.sort_link>
          </div>
        </div>
      </div>
      <div class="listings">
        <%= for listing <- @listings do %>
          <.live_component
          module={ListingCardComponent}
          id={listing.id}
          listing={listing}
          />
        <% end %>
      </div>

    <div class="footer">
      <div class="pagination">
        <.link
          :if={@options.page > 1}
          navigate={
            ~p"/listings?#{%{@options | page: @options.page - 1}}"
          }
        >
          Previous
        </.link>

        <.link
          :for={{page_number, current_page?} <- @pages}
          navigate={~p"/listings?#{%{@options | page: page_number}}"}
          class={if current_page?, do: "active"}
        >
          <%= page_number %>
        </.link>

        <.link
          :if={@more_pages?}
          navigate={
            ~p"/listings?#{%{@options | page: @options.page + 1}}"
          }
        >
          Next
        </.link>
      </div>
    </div>

    </div>
    """
  end

  def sort_link(assigns) do
    caret_or_v =
      if assigns.options.sort_order == :asc do
        "👆"
      else
        "👇"
      end
    params = %{
      assigns.options
      | sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)



    ~H"""
    <.link patch={~p"/listings?#{@params}"}>
      <%= caret_or_v %>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/listings?#{params}")

    {:noreply, socket}
  end

  def handle_event("sort-by", %{"sort-by" => sort_by}, socket) do
    sort_by = String.downcase(sort_by)
    params = %{socket.assigns.options | sort_by: sort_by}

    socket = push_patch(socket, to: ~p"/listings?#{params}")

    {:noreply, socket}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id make year) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default
    end
  end

  def more_pages?(options, pizza_order_count) do
    options.page * options.per_page < pizza_order_count
  end

  defp pages(options, donation_count) do
    page_count = ceil(donation_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end


end
