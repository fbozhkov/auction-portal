defmodule AuctionWeb.ListingsLive do
  use AuctionWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :listings, Auction.Listings.list_listings())}
  end

  def render(assigns) do
    ~H"""
    <div id="listings">
      <h3>All Listings</h3>
      <div class="listings">
        <%= for listing <- @listings do %>
          <div class="card">
            <.link patch={~p"/listings/#{listing.id}"}>
              <div class="thumbnail">
                <img src={~p"/images/car-logo.png"} % />
              </div>
            </.link>
            <div class="details">
              <h3><%= listing.make %> <%= listing.model %></h3>
              <p><%= listing.engine %> <%= listing.fuel %></p>
              <p><%= listing.year %> / <%= listing.odometer %> km</p>
              <p><%= listing.transmission %></p>
              <div class="bid">
                <p><%= listing.end_date %></p>
                <p class="price">Current bid: $<%= listing.current_bid%></p>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
