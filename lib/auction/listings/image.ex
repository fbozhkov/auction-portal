defmodule Auction.Listings.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :image_filename, :string
    belongs_to(:listing, Auction.Listings.Listing)

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:image_filename, :listing_id])
    |> validate_required([:image_filename])
  end
end
