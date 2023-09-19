defmodule AuctionWeb.ListingDetailsLive do
  use AuctionWeb, :live_view

  alias Auction.Listings

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div id="listing-details">

        <h2> <%= @listing.make %> <%= @listing.model %> </h2>
        <div class="wrapper">
          <div class="images">
            <img src={~p"/images/car-logo.png"} %>
          </div>
          <div class="border-container">
            <h3> Vehicle Information </h3>
            <div class="row">
              <span> Lot Number: </span>
              <span> <%= @listing.id %> </span>
            </div>
            <div class="row">
              <span> Make: </span>
              <span> <%= @listing.make %> </span>
            </div>
            <div class="row">
              <span> Model: </span>
              <span> <%= @listing.model %> </span>
            </div>
            <div class="row">
              <span> Year: </span>
              <span> <%= @listing.year %> </span>
            </div>
            <div class="row">
              <span> Odometer: </span>
              <span> <%= @listing.odometer %> </span>
            </div>
            <div class="row">
              <span> Engine: </span>
              <span> <%= @listing.engine %> </span>
            </div>
            <div class="row">
              <span> Transmission: </span>
              <span> <%= @listing.transmission %> </span>
            </div>
            <div class="row">
              <span> Fuel: </span>
              <span> <%= @listing.fuel %> </span>
            </div>
            <div class="row">
              <span> Color: </span>
              <span> <%= @listing.color %> </span>
            </div>
          </div>
          <div class="border-container">
            <h3> Bid Information </h3>
            <div class="row">
              <span> Time left: </span>
              <span> 01:03:12 </span>
            </div>

            <div class="row">
              <span> Current Bid: </span>
              <span> 0$ </span>
            </div>
            <.form>
              <p class="mb-2"> Your Bid: </p>
              <div class="flex">
                <p class="dollar"> $ </p>
                <input type="text" name="bid" placeholder="0">
              </div>
              <.button class="btn"> Place Bid </.button>
            </.form>
          </div>
        </div>

    </div>
    """
  end

  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:listing, Listings.get_listing!(id))}

  end

end
