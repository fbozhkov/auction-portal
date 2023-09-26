defmodule AuctionWeb.ListingsLive do
  use AuctionWeb, :live_view

  alias AuctionWeb.ListingCardComponent
  alias Auction.Listings

  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   :timer.send_interval(1000, self(), :tick)
    # end

    # socket = assign(socket, :time_left, nil)

    socket =
      assign(socket,
        keyword: "",
        loading: false)

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    per_page = param_to_integer(params["per_page"], 8)
    page = param_to_integer(params["page"], 1)

    options = %{
      per_page: per_page,
      page: page
    }

    listings = Listings.list_listings(options)
    socket = assign(socket, listings: listings, options: options)

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
      <div class="search">
        <form phx-submit="search">
          <input
            type="text"
            name="keyword"
            value={@keyword}
            placeholder="Keyword"
            autofocus
            autocomplete="off"
            list="matches"
            phx-debounce="500"
          />

          <button>
            <img src="/images/search.svg" />
          </button>
        </form>

        <.loader visable={@loading} />
      </div>
      <%!-- <pre>
        <%= inspect(assigns, pretty: true) %>
      </pre> --%>
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

  def handle_event("search", %{"keyword" => keyword}, socket) do
    send(self(), {:run_search, keyword})

    socket =
      assign(socket,
        keyword: keyword,
        listings: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_info({:run_search, keyword}, socket) do
    # IO.inspect(socket, label: ">>>>>>>>>>>>>>>>>>>>>>>socketBefore<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>")
    # socket =
    #   assign(socket,
    #     listings: Listings.search_by_keyword(keyword),
    #     loading: false,
    #     listings_count: length(Listings.search_by_keyword(keyword))
    #     )
    # IO.inspect(socket, label: ">>>>>>>>>>>>>>>>>>>>>>>AFTER<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>")
    socket =
      assign(socket,
        listings: Listings.search_by_keyword(keyword),
        loading: false,
        listings_count: length(Listings.search_by_keyword(keyword)),
        more_pages?: more_pages?(socket.assigns.options, length(Listings.search_by_keyword(keyword))),
        pages: pages(socket.assigns.options, length(Listings.search_by_keyword(keyword)))
      )
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

  def more_pages?(options, listing_count) do
    options.page * options.per_page < listing_count
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
