defmodule Auction.Repo.Migrations.CreateListings do
  use Ecto.Migration

  def change do
    create table(:listings) do
      add :make, :string
      add :model, :string
      add :year, :integer
      add :odometer, :integer
      add :engine, :string
      add :transmission, :string
      add :fuel, :string
      add :color, :string
      add :end_date, :utc_datetime
      add :minimum_price, :integer

      timestamps()
    end
  end
end
