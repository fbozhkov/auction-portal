defmodule AuctionWeb.MyListingsLive do
  use AuctionWeb, :live_view

  alias Auction.Listings
  alias Auction.Users.User

  alias AuctionWeb.ListingCardComponent

  on_mount({AuctionWeb.UserAuth, :mount_current_user})

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        my_listings: Listings.list_listings_by_user(socket.assigns.current_user.id),
        favourites: Listings.list_favourite_listings_by_user(socket.assigns.current_user.id)
      )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="my-listings">
      <div class="heading">
        <h2>My Listings</h2>
      </div>
      <div class="wrapper">
        <div class="listings">
          <div class="Favourites">
            <h3>Favourites</h3>
              <%= for favourite <- @favourites do %>
                <.live_component
                module={ListingCardComponent}
                id={favourite.id}
                listing={favourite}
                />
              <% end %>
          </div>
          <div class="MyListings">
            <h3>My Listings</h3>
              <%= for listing <- @my_listings do %>
                <.live_component
                module={ListingCardComponent}
                id={listing.id}
                listing={listing}
                />
              <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
