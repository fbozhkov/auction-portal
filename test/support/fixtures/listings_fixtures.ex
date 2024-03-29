defmodule Auction.ListingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Auction.Listings` context.
  """

  @doc """
  Generate a listing.
  """
  def listing_fixture(attrs \\ %{}) do
    {:ok, listing} =
      attrs
      |> Enum.into(%{
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
      })
      |> Auction.Listings.create_listing()

    listing
  end

  @doc """
  Generate a bid.
  """
  def bid_fixture(attrs \\ %{}) do
    {:ok, bid} =
      attrs
      |> Enum.into(%{
        bid: 42
      })
      |> Auction.Listings.create_bid()

    bid
  end

  @doc """
  Generate a image.
  """
  def image_fixture(attrs \\ %{}) do
    {:ok, image} =
      attrs
      |> Enum.into(%{
        image_filename: "some image_filename"
      })
      |> Auction.Listings.create_image()

    image
  end
end
