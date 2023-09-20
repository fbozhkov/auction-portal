defmodule AuctionWeb.ListingDetailsLive do
  use AuctionWeb, :live_view
  import AuctionWeb.UserAuth
  import Ecto.Changeset

  alias Auction.Listings
  alias Auction.Listings.Listing
  alias Auction.Listings.Bid
  alias Auction.Users

  on_mount({AuctionWeb.UserAuth, :mount_current_user})

  def mount(_params, session, socket) do
    {:ok, assign(socket, :bid, nil)}
  end

  def handle_params(%{"id" => id}, _, socket) do
    socket = assign(socket, :listing, Listings.get_listing!(id))

    current_user_id = socket.assigns.current_user.id
    listing_id = String.to_integer(id)
    payload = %{user_id: current_user_id, listing_id: listing_id}

    {:noreply, assign(socket, :payload, payload)}
  end

  def render(assigns) do
    ~H"""
    <div id="listing-details">
      <h2><%= @listing.make %> <%= @listing.model %></h2>
      <div class="wrapper">
        <div class="images">
          <img src={~p"/images/car-logo.png"} % />
        </div>
        <div class="border-container">
          <h3>Vehicle Information</h3>
          <div class="row">
            <span> Lot Number: </span>
            <span><%= @listing.id %></span>
          </div>
          <div class="row">
            <span> Make: </span>
            <span><%= @listing.make %></span>
          </div>
          <div class="row">
            <span> Model: </span>
            <span><%= @listing.model %></span>
          </div>
          <div class="row">
            <span> Year: </span>
            <span><%= @listing.year %></span>
          </div>
          <div class="row">
            <span> Odometer: </span>
            <span><%= @listing.odometer %></span>
          </div>
          <div class="row">
            <span> Engine: </span>
            <span><%= @listing.engine %></span>
          </div>
          <div class="row">
            <span> Transmission: </span>
            <span><%= @listing.transmission %></span>
          </div>
          <div class="row">
            <span> Fuel: </span>
            <span><%= @listing.fuel %></span>
          </div>
          <div class="row">
            <span> Color: </span>
            <span><%= @listing.color %></span>
          </div>
        </div>
        <div class="border-container">
          <h3>Bid Information</h3>
          <div class="row">
            <span> Time left: </span>
            <span> 01:03:12 </span>
          </div>

          <div class="row">
            <span> Current Bid: </span>
            <span> 0$ </span>
          </div>
          <form phx-submit="place_bid">
            <p class="mb-2">Your Bid:</p>
            <div class="flex">
              <p class="dollar">$</p>
              <input value={@bid} name="bid" type="text" placeholder="0" />
            </div>
            <.button class="btn">Place Bid</.button>
          </form>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("place_bid", %{"bid" => bid}, socket) do
    payload =
      socket.assigns.payload
      |> Map.put(:bid, bid)

    case Listings.create_bid(payload) do
      {:ok, _bid} ->
        socket = put_flash(socket, :info, "Bid placed successfully")
        changeset = Listings.change_bid(%Bid{})
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
