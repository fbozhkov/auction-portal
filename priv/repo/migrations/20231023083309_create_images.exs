defmodule Auction.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :image_filename, :string
      add :listing_id, references(:listings, on_delete: :delete_all)

      timestamps()
    end

    create index(:images, [:listing_id])
  end
end
