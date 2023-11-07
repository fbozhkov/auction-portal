defmodule AuctionWeb.CustomComponents do
  use Phoenix.Component

  import AuctionWeb.CoreComponents

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

  @doc """
  Switches page language

  """

  def lang_switcher(assigns) do

    other_lang = if assigns.locale == "en", do: "bg", else: "en"
    new_url = change_url(assigns.url, other_lang)

    ~H"""
    <div class="relative">
      <button class="dropdown-btn"
        phx-click={AuctionWeb.App.toggle_dropdown(assigns.id)}>
        <.icon name="hero-globe-europe-africa" class="dropdown-icon" />
      </button>
      <ul class="dropdown-content"
        id={assigns.id}
        phx-click-away={AuctionWeb.App.toggle_dropdown(assigns.id)}
      >
        <li class="dropdown-item">
          <a href={assigns.url}><%= String.capitalize(assigns.locale) %></a>
        </li>
        <li class="dropdown-item">
          <a href={new_url}><%= String.capitalize(other_lang) %></a>
        </li>
      </ul>
    </div>
    """
  end

  defp change_url(url, locale) do
    parts = String.split(url, "/", trim: true)
    rest_of_url = Enum.slice(parts, 1..-1) |> Enum.join("/")
    "/#{locale}/#{rest_of_url}"
  end
end
