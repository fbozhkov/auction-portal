defmodule Auction.Repo.Migrations.CreateBids do
  use Ecto.Migration

  def change do
    create table(:bids) do
      add :bid, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :listing_id, references(:listings, on_delete: :nothing)

      timestamps()
    end

    create index(:bids, [:user_id])
    create index(:bids, [:listing_id])
  end
end
