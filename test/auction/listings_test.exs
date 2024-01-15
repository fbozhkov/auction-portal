defmodule Auction.ListingsTest do
  use Auction.DataCase

  alias Auction.Listings

  describe "listings" do
    alias Auction.Listings.Listing

    import Auction.ListingsFixtures

    @invalid_attrs %{
      color: nil,
      end_date: nil,
      engine: nil,
      fuel: nil,
      make: nil,
      minimum_price: nil,
      model: nil,
      odometer: nil,
      transmission: nil,
      year: nil
    }

    test "list_listings/0 returns all listings" do
      listing = listing_fixture()
      assert Listings.list_listings() == [listing]
    end

    test "get_listing!/1 returns the listing with given id" do
      listing = listing_fixture()
      assert Listings.get_listing!(listing.id) == listing
    end

    test "create_listing/1 with valid data creates a listing" do
      valid_attrs = %{
        color: "some color",
        end_date: ~U[2023-09-14 11:07:00Z],
        engine: "some engine",
        fuel: "some fuel",
        make: "some make",
        minimum_price: 42,
        model: "some model",
        odometer: 42,
        transmission: "some transmission",
        year: 42
      }

      assert {:ok, %Listing{} = listing} = Listings.create_listing(valid_attrs)
      assert listing.color == "some color"
      assert listing.end_date == ~U[2023-09-14 11:07:00Z]
      assert listing.engine == "some engine"
      assert listing.fuel == "some fuel"
      assert listing.make == "some make"
      assert listing.minimum_price == 42
      assert listing.model == "some model"
      assert listing.odometer == 42
      assert listing.transmission == "some transmission"
      assert listing.year == 42
    end

    test "create_listing/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Listings.create_listing(@invalid_attrs)
    end

    test "update_listing/2 with valid data updates the listing" do
      listing = listing_fixture()

      update_attrs = %{
        color: "some updated color",
        end_date: ~U[2023-09-15 11:07:00Z],
        engine: "some updated engine",
        fuel: "some updated fuel",
        make: "some updated make",
        minimum_price: 43,
        model: "some updated model",
        odometer: 43,
        transmission: "some updated transmission",
        year: 43
      }

      assert {:ok, %Listing{} = listing} = Listings.update_listing(listing, update_attrs)
      assert listing.color == "some updated color"
      assert listing.end_date == ~U[2023-09-15 11:07:00Z]
      assert listing.engine == "some updated engine"
      assert listing.fuel == "some updated fuel"
      assert listing.make == "some updated make"
      assert listing.minimum_price == 43
      assert listing.model == "some updated model"
      assert listing.odometer == 43
      assert listing.transmission == "some updated transmission"
      assert listing.year == 43
    end

    test "update_listing/2 with invalid data returns error changeset" do
      listing = listing_fixture()
      assert {:error, %Ecto.Changeset{}} = Listings.update_listing(listing, @invalid_attrs)
      assert listing == Listings.get_listing!(listing.id)
    end

    test "delete_listing/1 deletes the listing" do
      listing = listing_fixture()
      assert {:ok, %Listing{}} = Listings.delete_listing(listing)
      assert_raise Ecto.NoResultsError, fn -> Listings.get_listing!(listing.id) end
    end

    test "change_listing/1 returns a listing changeset" do
      listing = listing_fixture()
      assert %Ecto.Changeset{} = Listings.change_listing(listing)
    end
  end

  describe "bids" do
    alias Auction.Listings.Bid

    import Auction.ListingsFixtures

    @invalid_attrs %{bid: nil}

    test "list_bids/0 returns all bids" do
      bid = bid_fixture()
      assert Listings.list_bids() == [bid]
    end

    test "get_bid!/1 returns the bid with given id" do
      bid = bid_fixture()
      assert Listings.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid" do
      valid_attrs = %{bid: 42}

      assert {:ok, %Bid{} = bid} = Listings.create_bid(valid_attrs)
      assert bid.bid == 42
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Listings.create_bid(@invalid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      update_attrs = %{bid: 43}

      assert {:ok, %Bid{} = bid} = Listings.update_bid(bid, update_attrs)
      assert bid.bid == 43
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Listings.update_bid(bid, @invalid_attrs)
      assert bid == Listings.get_bid!(bid.id)
    end

    test "delete_bid/1 deletes the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{}} = Listings.delete_bid(bid)
      assert_raise Ecto.NoResultsError, fn -> Listings.get_bid!(bid.id) end
    end

    test "change_bid/1 returns a bid changeset" do
      bid = bid_fixture()
      assert %Ecto.Changeset{} = Listings.change_bid(bid)
    end
  end
end
