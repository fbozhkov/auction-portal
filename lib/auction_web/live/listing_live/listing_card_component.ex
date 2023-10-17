defmodule AuctionWeb.ListingCardComponent do
  use AuctionWeb, :live_component

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, calculate_time_left(socket)}
  end

  def render(assigns) do
    ~H"""
    <div class="card" id={"listing-#{@id}"}>
      <.link patch={~p"/#{@locale}/listings/#{@listing.id}"}>
        <div class="thumbnail">
          <img src={~p"/images/car-logo.png"} % />
        </div>
      </.link>
      <div class="details">
        <h3><%= @listing.make %> <%= @listing.model %></h3>
        <p><%= @listing.engine %> <%= @listing.fuel %></p>
        <p><%= @listing.year %> / <%= @listing.odometer %> km</p>
        <p><%= @listing.transmission %></p>
        <div class="bid">
          <p><%= @listing.end_date %></p>
          <p class="price">
            <%= gettext("Current bid: $") %><%= @listing.current_bid %>
          </p>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(:tick, socket) do
    IO.inspect(socket)
    {:noreply, calculate_time_left(socket)}
  end

  defp calculate_time_left(socket) do
    now = DateTime.utc_now()
    timeleft = DateTime.diff(socket.assigns.end_date, now, :second)
    assign(socket, :time_left, timeleft)
  end
end
