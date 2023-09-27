defmodule Auction.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AuctionWeb.Telemetry,
      # Start the Ecto repository
      Auction.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Auction.PubSub},
      # Start the Auction Manager
      {Auction.AuctionManager, []},
      # Start Finch
      {Finch, name: Auction.Finch},
      # Start the Endpoint (http/https)
      AuctionWeb.Endpoint
      # Start a worker by calling: Auction.Worker.start_link(arg)
      # {Auction.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Auction.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AuctionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
