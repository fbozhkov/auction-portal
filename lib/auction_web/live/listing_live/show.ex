defmodule AuctionWeb.ListingLive.Show do
  use AuctionWeb, :live_view

  alias Auction.Listings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:listing, Listings.get_listing!(id))}
  end

  defp page_title(:show), do: "Show Listing"
  defp page_title(:edit), do: "Edit Listing"
end
