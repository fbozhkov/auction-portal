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

  @doc """
  Renders a button.

  ## Examples

      <.cbutton>Send!</.cbutton>
      <.cbutton phx-click="go" class="ml-2">Send!</.cbutton>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))
  attr(:bgg_color, :string, default: "bg-green-200")

  slot(:inner_block, required: true)

  def tbutton(assigns) do
    assigns = assign_new(assigns, :bg_color, fn -> @bgg_color end)

    ~H"""
    <button
      type={@type}
      class={[
        @class, @bgg_color
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end


  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))
  attr(:style, :string, default: nil)
  attr(:bgr_color, :string, default: "blue")
  attr(:size, :string, default: "medium")

  slot(:inner_block, required: true)

  def cbutton(assigns) do

    ~H"""
    <button
      type={@type}
      class={[

        @class
      ]}
      style={["
        background-color: #{@bgr_color};
        padding: #{props_map(@size)};
        border-radius: 4px;
        #{@style}
        "]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp props_map(key) do
    %{
      "small" => "4px",
      "medium" => "8px",
      "large" => "12px",
    }[key]
  end

end
