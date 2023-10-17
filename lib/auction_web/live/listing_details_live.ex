defmodule AuctionWeb.ListingDetailsLive do
  use AuctionWeb, :live_view

  alias Auction.Listings
  alias Auction.Users.User
  alias Auction.Users

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
        socket =
          assign(
            socket,
            listing: Listings.get_listing!(id),
            favourite: check_if_favourite(current_user.id, id)
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
        <%= if @current_user do %>
          <button phx-click="toggle_favorite">
            <%= if @favourite,
              do: "Remove from Favourites",
              else: "Add to Favourites" %>
          </button>
        <% end %>
      </div>
      <div class="wrapper">
        <div class="images">
          <img src={~p"/images/car-logo.png"} % />
        </div>
        <div class="border-container">
          <h3><%= gettext("Vehicle Information") %></h3>
          <div class="row">
            <span><%= gettext("Lot Number: ") %></span>
            <span><%= @listing.id %></span>
          </div>
          <div class="row">
            <span><%= gettext("Make: ") %></span>
            <span><%= @listing.make %></span>
          </div>
          <div class="row">
            <span><%= gettext("Model: ") %></span>
            <span><%= @listing.model %></span>
          </div>
          <div class="row">
            <span><%= gettext("Year: ") %></span>
            <span><%= @listing.year %></span>
          </div>
          <div class="row">
            <span><%= gettext("Odometer: ") %></span>
            <span><%= @listing.odometer %></span>
          </div>
          <div class="row">
            <span><%= gettext("Engine: ") %></span>
            <span><%= @listing.engine %></span>
          </div>
          <div class="row">
            <span><%= gettext("Transmission: ") %></span>
            <span><%= @listing.transmission %></span>
          </div>
          <div class="row">
            <span><%= gettext("Fuel: ") %></span>
            <span><%= @listing.fuel %></span>
          </div>
          <div class="row">
            <span><%= gettext("Color: ") %></span>
            <span><%= @listing.color %></span>
          </div>
        </div>
        <div class="border-container">
          <h3><%= gettext("Bid Information") %></h3>
          <div class="row">
            <span><%= gettext("Auction end: ") %></span>
            <span><%= @listing.end_date %></span>
          </div>
          <div class="row">
            <span><%= gettext("Time left: ") %></span>
            <span><%= @time_left %></span>
          </div>
          <div class="row">
            <span><%= gettext("Current Bid: ") %></span>
            <span><%= @listing.current_bid %>$</span>
          </div>
          <%= if @current_user do %>
            <form phx-submit="place_bid" phx-change="validate">
              <p class="mb-2"><%= gettext("Your Bid:") %></p>
              <div class="flex">
                <p class="dollar">$</p>
                <input value={@bid} name="bid" type="text" placeholder="0" />
              </div>
              <.button class="btn"><%= gettext("Place Bid") %></.button>
            </form>
          <% else %>
            <p>
              <%= gettext("You need to ") %><a href="/users/log_in"><%= gettext "log in" %></a>
              <%= gettext("in order to bid.") %>
            </p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("toggle_favorite", _, socket) do
    current_user = socket.assigns.current_user
    listing_id = socket.assigns.listing.id

    case socket.assigns.favourite do
      true ->
        Users.delete_favourite(current_user.id, listing_id)
        socket = assign(socket, :favourite, false)
        {:noreply, socket}

      false ->
        Users.create_favourite(%{user_id: current_user.id, listing_id: listing_id})
        socket = assign(socket, :favourite, true)
        {:noreply, socket}
    end
  end

  def handle_event("validate", params, socket) do
    case Integer.parse(params["bid"]) do
      {bid, ""} when bid > socket.assigns.listing.current_bid ->
        socket = clear_flash(socket)
        {:noreply, assign(socket, :bid, bid)}

      _ ->
        socket = put_flash(socket, :error, gettext("Bid must be greater than current bid"))
        {:noreply, assign(socket, :bid, nil)}
    end
  end

  def handle_event("place_bid", %{"bid" => bid}, socket) do
    payload =
      socket.assigns.payload
      |> Map.put(:bid, String.to_integer(bid))

    case Listings.update_listing_bid(socket.assigns.listing, payload) do
      {:ok, _listing} ->
        socket = put_flash(socket, :info, gettext("Current bid updated %{bid}", bid: bid))
        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, gettext("Error updating bid %{bid}", bid: bid))
        {:noreply, socket}
    end
  end

  def handle_info({:new_listing_bid, listing}, socket) do
    {:noreply, assign(socket, :listing, listing)}
  end

  def handle_info(:tick, socket) do
    # IO.inspect(socket)
    {:noreply, calculate_time_left(socket)}
  end

  defp calculate_time_left(socket) do
    now = DateTime.utc_now()
    timeleft = DateTime.diff(socket.assigns.listing.end_date, now, :second)

    days = div(timeleft, 86_400)
    hours = div(rem(timeleft, 86_400), 3_600)
    minutes = div(rem(timeleft, 3_600), 60)
    seconds = rem(timeleft, 60)

    formatted_time_left =
      gettext("%{days}D %{hours}H %{minutes} min %{seconds} sec", %{
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds
      })

    assign(socket, :time_left, formatted_time_left)
  end

  def check_if_favourite(user_id, listing_id) do
    result = Users.check_if_listing_is_favourite(user_id, listing_id)

    if Enum.empty?(result) do
      false
    else
      true
    end
  end
end
