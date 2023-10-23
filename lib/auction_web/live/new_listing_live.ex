defmodule AuctionWeb.NewListingLive do
  use AuctionWeb, :live_view

  alias Auction.Listings
  alias Auction.Listings.Listing

  def mount(_params, _session, socket) do
    socket =
      allow_upload(
        socket,
        :photos,
        accept: ~w(.png .jpg .jpeg .webp),
        max_entries: 3,
        max_file_size: 8_000_000
      )
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

          <div class="hint">
            Add up to <%= @uploads.photos.max_entries %> photos
            (max <%= trunc(@uploads.photos.max_file_size / 1_000_000) %> MB each)
          </div>

          <div class="drop" phx-drop-target={@uploads.photos.ref}>
            <div>
              <img src="/images/upload.svg">
              <div>
                <label for={@uploads.photos.ref}>
                  <span>Upload a file</span>
                  <.live_file_input upload={@uploads.photos} class="sr-only" />
                </label>
                <span>or drag and drop here</span>
              </div>
              <p>
                <%= @uploads.photos.max_entries %> photos max,
                up to <%= trunc(@uploads.photos.max_file_size / 1_000_000) %> MB each
              </p>
            </div>
          </div>

          <.error :for={err <- upload_errors(@uploads.photos)}>
            <%= Phoenix.Naming.humanize(err) %>
          </.error>

          <div :for={entry <- @uploads.photos.entries} class="entry">
            <.live_img_preview entry={entry} />

            <div class="progress">
              <div class="value">
                <%= entry.progress %>%
              </div>
              <div class="bar">
                <span style={"width: #{entry.progress}%"}></span>
              </div>
              <.error :for={err <- upload_errors(@uploads.photos, entry)}>
                <%= Phoenix.Naming.humanize(err) %>
              </.error>
            </div>

            <a phx-click="cancel" phx-value-ref={entry.ref}>
              &times;
            </a>
          </div>
          <div>
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
          </div>
          <.button><%= gettext("Save") %></.button>
        </.form>
      </div>
    </div>
    """
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  def handle_event("save", %{"listing" => listing_params}, socket) do
    listing_params = Map.put(listing_params, "seller_id", socket.assigns.current_user.id)

    image_upload =
      consume_uploaded_entries(socket, :photos, fn meta, entry ->
        dest =
          Path.join([
            "priv",
            "static",
            "uploads",
            "#{entry.uuid}-#{entry.client_name}"
          ])

        File.cp!(meta.path, dest)

        url_path = static_path(socket, "/uploads/#{Path.basename(dest)}")
        image_name = Path.basename(dest)

        {:ok, image_name}
      end)

    IO.inspect(image_upload, label: "image_upload>>>>>>>>>>>>>>>>>>>>>>>>")

    listing_params = Map.put(listing_params, "image_upload", image_upload)

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
