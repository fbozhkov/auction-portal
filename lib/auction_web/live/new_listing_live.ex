defmodule AuctionWeb.NewListingLive do
  use AuctionWeb, :live_view

  alias Auction.Listings
  alias Auction.Listings.Listing

  def mount(socket) do
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    changeset = Listings.change_listing(%Listing{seller_id: socket.assigns.current_user.id})

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div id="new-listing">
      <h1><%= gettext("New Listing") %></h1>
      <div>
        <.form
          for={@form}
          id="new-listing-form"
          phx-submit="save"
          phx-change="validate"
        >
          <div class="field">
            <.input
              field={@form[:make]}
              type="text"
              label={gettext("Make")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:model]}
              type="text"
              label={gettext("Model")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:year]}
              type="number"
              label={gettext("Year")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:odometer]}
              type="number"
              label={gettext("Odometer")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:engine]}
              type="text"
              label={gettext("Engine")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:transmission]}
              type="text"
              label={gettext("Transmission")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:fuel]}
              type="text"
              label={gettext("Fuel")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:color]}
              type="text"
              label={gettext("Color")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:end_date]}
              type="datetime-local"
              label={gettext("End date")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:minimum_price]}
              type="number"
              label={gettext("Minimum price")}
            />
          </div>
          <div class="field">
            <.input
              field={@form[:current_bid]}
              type="number"
              label={gettext("Starting price")}
            />
          </div>
          <.button><%= gettext("Save") %></.button>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"listing" => listing_params}, socket) do
    listing_params = Map.put(listing_params, "seller_id", socket.assigns.current_user.id)

    case Listings.create_listing(listing_params) do
      {:ok, listing} ->
        socket = push_navigate(socket, to: ~p"/listings/#{listing.id}")
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, form: to_form(changeset))
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"listing" => listing_params}, socket) do
    changeset =
      %Listing{}
      |> Listings.change_listing(listing_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
