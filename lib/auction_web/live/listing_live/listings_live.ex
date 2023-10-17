defmodule AuctionWeb.ListingsLive do
  use AuctionWeb, :live_view

  alias AuctionWeb.SortOptionsComponent
  alias AuctionWeb.ListingCardComponent
  alias Auction.Listings

  def mount(%{"locale" => locale}, _session, socket) do
    socket =
      assign(socket,
        loading: false,
        locale: locale
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)
    per_page = param_to_integer(params["per_page"], 8)
    page = param_to_integer(params["page"], 1)

    options = %{
      keyword: "",
      sort_by: sort_by,
      sort_order: sort_order,
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
      <div class="search">
        <form phx-submit="search">
          <input
            type="text"
            name="keyword"
            value={@options.keyword}
            placeholder={gettext("Keyword")}
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
      <div class="sort-filter">
        <form phx-change="select-per-page">
          <select name="per-page">
            <%= Phoenix.HTML.Form.options_for_select(
              [8, 12, 16, 20],
              @options.per_page
            ) %>
          </select>
          <label for="per-page"><%= gettext("per page") %></label>
        </form>
        <.live_component
          module={SortOptionsComponent}
          id="sort-options"
          options={@options}
          locale={@locale}
        />
      </div>
      <div class="listings">
        <%= for listing <- @listings do %>
          <.live_component
            module={ListingCardComponent}
            id={listing.id}
            listing={listing}
            locale={@locale}
          />
        <% end %>
      </div>

      <div class="footer">
        <div class="pagination">
          <.link
            :if={@options.page > 1}
            navigate={
              ~p"/#{@locale}/listings?#{%{@options | page: @options.page - 1}}"
            }
          >
            <%= gettext("Previous") %>
          </.link>

          <.link
            :for={{page_number, current_page?} <- @pages}
            navigate={
              ~p"/#{@locale}/listings?#{%{@options | page: page_number}}"
            }
            class={if current_page?, do: "active"}
          >
            <%= page_number %>
          </.link>

          <.link
            :if={@more_pages?}
            navigate={
              ~p"/#{@locale}/listings?#{%{@options | page: @options.page + 1}}"
            }
          >
            <%= gettext("Next") %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"keyword" => keyword}, socket) do
    send(self(), {:run_search, keyword})
    params = %{socket.assigns.options | keyword: keyword}
    locale = socket.assigns.locale
    socket = push_patch(socket, to: ~p"/#{locale}/listings?#{params}")

    socket =
      assign(socket,
        listings: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    locale = socket.assigns.locale
    socket = push_patch(socket, to: ~p"/#{locale}/listings?#{params}")

    {:noreply, socket}
  end

  def handle_info({:sort_option_changed, params}, socket) do
    locale = socket.assigns.locale
    socket = push_patch(socket, to: ~p"/#{locale}/listings?#{params}")

    {:noreply, socket}
  end

  def handle_info({:sort_order_changed, params}, socket) do
    locale = socket.assigns.locale
    socket = push_patch(socket, to: ~p"/#{locale}/listings?#{params}")

    {:noreply, socket}
  end

  def handle_info({:run_search, keyword}, socket) do
    socket =
      assign(socket,
        listings: Listings.search_by_keyword(keyword),
        loading: false,
        listings_count: length(Listings.search_by_keyword(keyword)),
        more_pages?:
          more_pages?(socket.assigns.options, length(Listings.search_by_keyword(keyword))),
        pages: pages(socket.assigns.options, length(Listings.search_by_keyword(keyword)))
      )

    {:noreply, socket}
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
