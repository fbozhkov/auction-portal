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
    current_lang = assigns.locale
    url = assigns.url

    other_lang = if current_lang == "en", do: "bg", else: "en"
    new_url = change_url(url, other_lang)

    ~H"""
    <div class="relative">
      <button class="dropdown-btn" onclick="toggleDropdown()">
        <.icon name="hero-globe-europe-africa" class="dropdown-icon"></.icon>
      </button>
      <ul class="dropdown-content" id="dropdown">
          <li class="dropdown-item"><a href={url}><%=String.capitalize(current_lang)%></a></li>
          <li class="dropdown-item"><a href={new_url}><%=String.capitalize(other_lang)%></a></li>
      </ul>
    </div>
    """
    # ~H"""
    #   <select name="lang">

    #     <option id={current_lang} value={current_lang}>

    #         <%= String.capitalize(current_lang)%>

    #     </option>
    #     <option id={other_lang} value={other_lang}>
    #       <a href={"/#{new_url}"}>
    #         <%=String.capitalize(other_lang)%>
    #       </a>
    #     </option>
    #   </select>
    # """
  end

  defp change_url(url, locale) do
    [_, _ | rest_url] = String.split(url, "/")
    "/#{locale}/#{rest_url}"
  end
end
