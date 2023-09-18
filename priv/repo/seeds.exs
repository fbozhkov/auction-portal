# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Auction.Repo.insert!(%Auction.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Auction.Repo
alias Auction.Listings.Listing
import DateTime

%Listing{
  make: "BMW",
  model: "540",
  year: 1997,
  odometer: 200_000,
  engine: "4.4 V8",
  transmission: "Automatic",
  fuel: "petrol",
  color: "Black",
  end_date: DateTime.new!(~D[2023-10-05], ~T[10:00:00], "Etc/UTC"),
  minimum_price: 4000
}
|> Repo.insert()

%Listing{
  make: "Toyota",
  model: "Camry",
  year: 2010,
  odometer: 100_000,
  engine: "2.5 V6",
  transmission: "Automatic",
  fuel: "petrol",
  color: "White",
  end_date: DateTime.new!(~D[2023-10-05], ~T[00:00:00], "Etc/UTC"),
  minimum_price: 4000
}
|> Repo.insert()

%Listing{
  make: "Toyota",
  model: "Corolla",
  year: 2015,
  odometer: 50_000,
  engine: "1.8 I4",
  transmission: "Automatic",
  fuel: "petrol",
  color: "Black",
  end_date: DateTime.new!(~D[2023-10-05], ~T[00:00:00], "Etc/UTC"),
  minimum_price: 5000
}
|> Repo.insert()

%Listing{
  make: "Mercedes",
  model: "C-Class",
  year: 2018,
  odometer: 20_000,
  engine: "2.0 I4",
  transmission: "Automatic",
  fuel: "petrol",
  color: "Black",
  end_date: DateTime.new!(~D[2023-10-05], ~T[00:00:00], "Etc/UTC"),
  minimum_price: 10_000
}
|> Repo.insert()

%Listing{
  make: "Mercedes",
  model: "E-Class",
  year: 2019,
  odometer: 10_000,
  engine: "3.0 I6",
  transmission: "Automatic",
  fuel: "diesel",
  color: "Black",
  end_date: DateTime.new!(~D[2023-10-05], ~T[00:00:00], "Etc/UTC"),
  minimum_price: 35_000
}
|> Repo.insert()
