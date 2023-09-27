defmodule Auction.Repo.Migrations.CreateUserShortlist do
  use Ecto.Migration

  def change do
    create table(:user_shortlist) do
      add :shortlist_type, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :listing_id, references(:listings, on_delete: :nothing)

      timestamps()
    end

    create index(:user_shortlist, [:user_id])
    create index(:user_shortlist, [:listing_id])
  end
end
