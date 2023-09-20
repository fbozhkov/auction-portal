defmodule AuctionWeb.ListingLive.FormComponent do
  use AuctionWeb, :live_component

  alias Auction.Listings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          Use this form to manage listing records in your database.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="listing-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:make]} type="text" label="Make" />
        <.input field={@form[:model]} type="text" label="Model" />
        <.input field={@form[:year]} type="number" label="Year" />
        <.input field={@form[:odometer]} type="number" label="Odometer" />
        <.input field={@form[:engine]} type="text" label="Engine" />
        <.input
          field={@form[:transmission]}
          type="text"
          label="Transmission"
        />
        <.input field={@form[:fuel]} type="text" label="Fuel" />
        <.input field={@form[:color]} type="text" label="Color" />
        <.input
          field={@form[:end_date]}
          type="datetime-local"
          label="End date"
        />
        <.input
          field={@form[:minimum_price]}
          type="number"
          label="Minimum price"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Listing</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{listing: listing} = assigns, socket) do
    changeset = Listings.change_listing(listing)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"listing" => listing_params}, socket) do
    changeset =
      socket.assigns.listing
      |> Listings.change_listing(listing_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"listing" => listing_params}, socket) do
    save_listing(socket, socket.assigns.action, listing_params)
  end

  defp save_listing(socket, :edit, listing_params) do
    case Listings.update_listing(socket.assigns.listing, listing_params) do
      {:ok, listing} ->
        notify_parent({:saved, listing})

        {:noreply,
         socket
         |> put_flash(:info, "Listing updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_listing(socket, :new, listing_params) do
    case Listings.create_listing(listing_params) do
      {:ok, listing} ->
        notify_parent({:saved, listing})

        {:noreply,
         socket
         |> put_flash(:info, "Listing created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
