defmodule AuctionWeb.ListingsLive do
  use AuctionWeb, :live_view

  alias AuctionWeb.ListingCardComponent
  alias Auction.Listings

  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   :timer.send_interval(1000, self(), :tick)
    # end

    # socket = assign(socket, :time_left, nil)

    {:ok, socket, temporary_assigns: [listings: []]}
  end

  def handle_params(params, _uri, socket) do
    per_page = param_to_integer(params["per_page"], 8)
    page = param_to_integer(params["page"], 1)

    options = %{
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
      <form phx-change="select-per-page">
        <select name="per-page">
          <%= Phoenix.HTML.Form.options_for_select(
            [8, 12, 16, 20],
            @options.per_page
          ) %>
        </select>
        <label for="per-page">per page</label>
      </form>
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

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/listings?#{params}")

    {:noreply, socket}
  end

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
