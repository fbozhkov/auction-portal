defmodule Auction.Repo.Migrations.AddSellerId do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :seller_id, references(:users, on_delete: :nothing)
    end
  end
end
