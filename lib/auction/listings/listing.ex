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
    has_many(:bids, Auction.Listings.Bid)

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
      :minimum_price
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
      :minimum_price
    ])
  end
end
