defmodule AuctionWeb.ListingsLive do
  use AuctionWeb, :live_view

  alias AuctionWeb.ListingCardComponent

  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   :timer.send_interval(1000, self(), :tick)
    # end

    # socket = assign(socket, :time_left, nil)

    {:ok, assign(socket, :listings, Auction.Listings.list_listings())}
  end

  def render(assigns) do
    ~H"""
    <div id="listings">
      <h3>All Listings</h3>
      <div class="listings">
        <%= for listing <- @listings do %>
          <.live_component
          module={ListingCardComponent}
          id={listing.id}
          listing={listing}
          />
        <% end %>
      </div>
    </div>
    """
  end



end
