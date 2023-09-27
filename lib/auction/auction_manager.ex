defmodule Auction.AuctionManager do
  use GenServer
  alias Auction.Listings
  alias Auction.Listings.Listing

  def start_link(_args) do
    IO.puts("Starting Auction Manager")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    {:ok, state}
  end

  # Add your GenServer callback functions here

  def handle_info({:end_auction, listing_id}, state) do
    # Retrieve the listing by its ID from the database
    #listing = Repo.get(Listing, listing_id)
    listing = Listings.get_listing!(listing_id)

    # Check if the listing is still active (i.e., end_date hasn't passed)
    if DateTime.now("UTC") < listing.end_date do
      # The end_date hasn't been reached; do nothing
      {:noreply, state}
    else
      # The end_date has been reached; implement logic to end the auction,
      # notify users, and update the database
      # ...
      Listings.delete_listing(listing_id)

      {:noreply, state}
    end
  end
end
