defmodule Auction.Repo.Migrations.AddCurrentBid do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :current_bid, :integer
    end
  end
end
