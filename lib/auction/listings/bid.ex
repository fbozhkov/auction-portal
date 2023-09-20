defmodule Auction.Listings.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bids" do
    field(:bid, :integer)
    belongs_to(:user, Auction.Listings.User)
    belongs_to(:listing, Auction.Listings.Listing)

    timestamps()
  end

  @doc false
  def changeset(bid, attrs) do
    bid
    |> cast(attrs, [:bid, :user_id, :listing_id])
    |> validate_required([:bid])
  end
end
