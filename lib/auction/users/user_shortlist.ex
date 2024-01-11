defmodule Auction.Users.UserShortlist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_shortlist" do
    field :shortlist_type, :string
    belongs_to :user, Auction.Users.User
    belongs_to :listing, Auction.Listings.Listing

    timestamps()
  end

  @doc false
  def changeset(user_shortlist, attrs) do
    user_shortlist
    |> cast(attrs, [:shortlist_type, :user_id, :listing_id])
    |> validate_required([:shortlist_type])
  end
end
