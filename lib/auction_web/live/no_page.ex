defmodule AuctionWeb.NoPage do
  use AuctionWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="no-page">
      <h1>Page not found</h1>
      <p>
        The page you're looking for doesn't exist.
        You may have mistyped the address or the page may have moved.
      </p>
      <.link navigate={~p"/"}>
        <.button>Go to home page</.button>
      </.link>
    </div>
    """
  end
end
