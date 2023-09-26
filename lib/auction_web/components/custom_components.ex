defmodule AuctionWeb.CustomComponents do
  use Phoenix.Component

  attr :expiration, :integer, required: true
  # attr :expiration, :integer, default: 24
  slot :legal, required: true
  slot :inner_block, required: true

  def promo(assigns) do
    assigns = assign(assigns, :minutes, assigns.expiration * 60)

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= @minutes %> minutes
      </div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end

  def loader(assigns) do
    ~H"""
    <div :if={@visable} class="loader">
      Loading...
    </div>
    """
  end
end
