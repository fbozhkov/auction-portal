defmodule AuctionWeb.ListingDetailsLive do
  use AuctionWeb, :live_view

  alias Auction.Listings
  alias Auction.Listings.Bid
  alias Auction.Users.User

  on_mount({AuctionWeb.UserAuth, :mount_current_user})

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Listings.subscribe()
      :timer.send_interval(1000, self(), :tick)
    end
    socket = assign(socket, :time_left, nil)

    {:ok, assign(socket, :bid, nil)}
  end



  def handle_params(%{"id" => id}, _, socket) do
    case socket.assigns.current_user do
      nil ->
        socket = assign(socket, :listing, Listings.get_listing!(id))
        {:noreply, socket}

      %User{} = current_user ->
        socket = assign(
          socket,
          listing: Listings.get_listing!(id)
          )
        listing_id = String.to_integer(id)
        payload = %{user_id: current_user.id, listing_id: listing_id}
        {:noreply, assign(socket, :payload, payload)}
    end
  end

  def render(assigns) do
    ~H"""
    <div id="listing-details">
      <div class="heading">
        <h2><%= @listing.make %> <%= @listing.model %></h2>
        <button phx-click="toggle_favorite">
          <%!-- <%= if @favorite, do: "Add to Favorites", else: "Remove from Favorites" %> --%>
        </button>
      </div>
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
            <span> End time: </span>
            <span> <%= @listing.end_date %> </span>
          </div>
          <div class="row">
            <span> Time left: </span>
            <span> <%= @time_left %> </span>
          </div>
          <div class="row">
            <span> Current Bid: </span>
            <span> <%= @listing.current_bid %>$ </span>
          </div>
          <%= if @current_user do %>
            <form phx-submit="place_bid" phx-change="validate">
              <p class="mb-2">Your Bid:</p>
              <div class="flex">
                <p class="dollar">$</p>
                <input value={@bid} name="bid" type="text" placeholder="0" />
              </div>
              <.button class="btn">Place Bid</.button>
            </form>
          <% else %>
            <p>You need to <a href="/users/log_in">log in</a> in order to bid.</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("validate", params, socket) do
    case Integer.parse(params["bid"]) do
      {bid, ""} when bid > socket.assigns.listing.current_bid ->
        socket = clear_flash(socket)
        {:noreply, assign(socket, :bid, bid)}

      _ ->
        socket = put_flash(socket, :error, "Bid must be greater than current bid")
        {:noreply, assign(socket, :bid, nil)}
    end
  end

  def handle_event("place_bid", %{"bid" => bid}, socket) do
    payload =
      socket.assigns.payload
      |> Map.put(:bid, String.to_integer(bid))

    case Listings.update_listing_bid(socket.assigns.listing, payload) do
      {:ok, listing} ->
        socket = put_flash(socket, :info, "Current bid updated #{bid}")
        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Error updating bid #{bid}")
        {:noreply, socket}
    end
  end

  def handle_info({:new_listing_bid, listing}, socket) do
    {:noreply, assign(socket, :listing, listing)}
  end

  def handle_info(:tick, socket) do
    #IO.inspect(socket)
    {:noreply, calculate_time_left(socket)}
  end

  defp calculate_time_left(socket) do
    now = DateTime.utc_now()
    timeleft = DateTime.diff(socket.assigns.listing.end_date, now, :second)

    days = div(timeleft, 86_400)
    hours = div(rem(timeleft, 86_400), 3_600)
    minutes = div(rem(timeleft, 3_600), 60)
    seconds = rem(timeleft, 60)

    formatted_time_left = "#{days}D #{hours}H #{minutes} min #{seconds} sec"

    assign(socket, :time_left, formatted_time_left)
  end

end
