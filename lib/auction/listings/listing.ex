defmodule Auction.Listings.Listing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "listings" do
    field(:color, :string)
    field(:end_date, :utc_datetime)
    field(:engine, :string)
    field(:fuel, :string)
    field(:make, :string)
    field(:minimum_price, :integer)
    field(:model, :string)
    field(:odometer, :integer)
    field(:transmission, :string)
    field(:year, :integer)
    field(:current_bid, :integer)
    field(:seller_id, :integer)
    field(:image_upload, :string)
    has_many :bids, Auction.Listings.Bid, on_delete: :delete_all
    many_to_many :users, Auction.Users.User, join_through: Auction.Users.UserShortlist

    timestamps()
  end

  @doc false
  def changeset(listing, attrs) do
    listing
    |> cast(attrs, [
      :make,
      :model,
      :year,
      :odometer,
      :engine,
      :transmission,
      :fuel,
      :color,
      :end_date,
      :minimum_price,
      :current_bid,
      :seller_id,
      :image_upload
    ])
    |> validate_required([
      :make,
      :model,
      :year,
      :odometer,
      :engine,
      :transmission,
      :fuel,
      :color,
      :end_date,
      :minimum_price,
      :current_bid,
      :seller_id
    ])
  end
end
