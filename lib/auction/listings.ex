defmodule Auction.Listings do
  @moduledoc """
  The Listings context.
  """

  import Ecto.Query, warn: false
  alias Auction.Repo

  alias Auction.Listings.Listing
  alias Auction.Listings.Bid
  alias Auction.Users

  def subscribe do
    Phoenix.PubSub.subscribe(Auction.PubSub, "livebids")
  end

  def broadcast(message) do
    Phoenix.PubSub.broadcast(Auction.PubSub, "livebids", message)
  end

  @doc """
  Search listings by keyword.
  """

  def search_by_keyword(keyword) do
    query =
      from(l in Listing,
        where: ilike(l.make, ^"%#{keyword}%") or
              ilike(l.model, ^"%#{keyword}%") or
              ilike(l.color, ^"%#{keyword}%"),
        select: l
      )
    Repo.all(query)
  end



  @doc """
  Returns the list of listings.

  ## Examples

      iex> list_listings()
      [%Listing{}, ...]

  """
  def list_listings do
    Repo.all(from l in Listing, order_by: [desc: l.end_date])
  end

  def list_listings_by_user(user_id) do
    Repo.all(from l in Listing, where: l.user_id == ^user_id, order_by: [desc: l.end_date])
  end

  def list_favourite_listings_by_user(user_id) do

    listing_ids = Users.list_user_favourites_ids(user_id)
    Repo.all(from l in Listing, where: l.id in ^listing_ids, order_by: [desc: l.end_date])
  end


  @doc """
  Returns a list of listings based on the given `options`.
  """
  def list_listings(options) when is_map(options) do
    from(Listing)
    |> sort(options)
    |> paginate(options)
    |> Repo.all()
  end

  defp sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
    order_by(query, {^sort_order, ^sort_by})
  end

  defp paginate(query, %{page: page, per_page: per_page}) do
    offset = max(page - 1, 0) * per_page

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  defp paginate(query, _options), do: query

  def listing_count do
    Repo.aggregate(Listing, :count, :id)
  end

  @doc """
  Gets a single listing.

  Raises `Ecto.NoResultsError` if the Listing does not exist.

  ## Examples

      iex> get_listing!(123)
      %Listing{}

      iex> get_listing!(456)
      ** (Ecto.NoResultsError)

  """
  # def get_listing!(id), do: Repo.get!(Listing, id)
  def get_listing!(id) do
    Listing
    |> Repo.get!(id)
    |> Repo.preload(:bids)
  end

  @doc """
  Creates a listing.

  ## Examples

      iex> create_listing(%{field: value})
      {:ok, %Listing{}}

      iex> create_listing(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_listing(attrs \\ %{}) do
    %Listing{}
    |> Listing.changeset(attrs)
    |> Repo.insert()
    |> create_auction_process()
  end

  defp create_auction_process({:ok, listing}) do
    # Calculate the time difference until the end_date
    time_difference = DateTime.diff(listing.end_date, DateTime.utc_now(), :millisecond)

    # Schedule the task to end the auction when end_date is reached
    Process.send_after(Auction.AuctionManager, {:end_auction, listing.id}, time_difference)

    {:ok, listing}
  end

  defp create_auction_process(_error) do
    # Handle errors here, e.g., return an error tuple or raise an exception
  end

  @doc """
  Updates a listing.

  ## Examples

      iex> update_listing(listing, %{field: new_value})
      {:ok, %Listing{}}

      iex> update_listing(listing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_listing(%Listing{} = listing, attrs) do
    listing
    |> Listing.changeset(attrs)
    |> Repo.update()
  end

  def update_listing_bid(%Listing{} = listing, attrs) do
    create_bid(attrs)

    {:ok, listing} =
      listing
      |> update_listing(%{current_bid: attrs.bid})

    broadcast({:new_listing_bid, listing})

    {:ok, listing}
  end

  @doc """
  Deletes a listing.

  ## Examples

      iex> delete_listing(listing)
      {:ok, %Listing{}}

      iex> delete_listing(listing)
      {:error, %Ecto.Changeset{}}

  """
  def delete_listing(%Listing{} = listing) do
    Repo.delete(listing)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking listing changes.

  ## Examples

      iex> change_listing(listing)
      %Ecto.Changeset{data: %Listing{}}

  """
  def change_listing(%Listing{} = listing, attrs \\ %{}) do
    Listing.changeset(listing, attrs)
  end

  alias Auction.Listings.Bid

  @doc """
  Returns the list of bids.

  ## Examples

      iex> list_bids()
      [%Bid{}, ...]

  """
  def list_bids do
    Repo.all(Bid)
  end

  @doc """
  Gets a single bid.

  Raises `Ecto.NoResultsError` if the Bid does not exist.

  ## Examples

      iex> get_bid!(123)
      %Bid{}

      iex> get_bid!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bid!(id), do: Repo.get!(Bid, id)

  @doc """
  Creates a bid.

  ## Examples

      iex> create_bid(%{field: value})
      {:ok, %Bid{}}

      iex> create_bid(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bid(attrs \\ %{}) do
    %Bid{}
    |> Bid.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bid.

  ## Examples

      iex> update_bid(bid, %{field: new_value})
      {:ok, %Bid{}}

      iex> update_bid(bid, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bid(%Bid{} = bid, attrs) do
    bid
    |> Bid.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bid.

  ## Examples

      iex> delete_bid(bid)
      {:ok, %Bid{}}

      iex> delete_bid(bid)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bid(%Bid{} = bid) do
    Repo.delete(bid)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bid changes.

  ## Examples

      iex> change_bid(bid)
      %Ecto.Changeset{data: %Bid{}}

  """
  def change_bid(%Bid{} = bid, attrs \\ %{}) do
    Bid.changeset(bid, attrs)
  end
end
