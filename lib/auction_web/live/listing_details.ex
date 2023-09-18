defmodule AuctionWeb.ListingLive do
  use AuctionWeb, :live_view

  alias Auction.Listings

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div id="listing-details">
        <h3> <%= @listing.make %> <%= @listing.model %> </h3>
        <div>
          <div class="images">
            <img src={~p"/images/car-logo.png"} %>
          </div>
          <div class="info">
            <h3> Vehicle Information </h3>
            <div>
              <span> Lot Number: </span>
              <span> <%= @listing.id %> </span>
            </div>
          </div>
          <div class="bidding">

          </div>
        </div>
      </div>
    """
  end

end
