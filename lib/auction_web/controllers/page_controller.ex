defmodule AuctionWeb.PageController do
  use AuctionWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    current_url = conn.path_info
    render(conn, :home, layout: false, current_url: current_url)
  end
end
