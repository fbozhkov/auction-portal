defmodule AuctionWeb.CssLive do
  use AuctionWeb, :live_view

  def mount(%{"locale" => locale}, _session, socket) do
    socket =
      assign(socket,
        locale: locale
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="css">
      <div style="max-width:1200px; padding-top: 8rem; margin: 0 auto; display: flex; gap:2rem; flex-direction:column; align-items:baseline;">
        <h1>Buttons</h1>
          <h3>Using core components</h3>
          <.button style="background-color:red; padding:0.5rem; border-radius:4px">
            inline
          </.button>
          <.button class="custom-btn">
            stylesheet
          </.button>

          <h3>Using custom components</h3>
          <.tbutton>
            default
          </.tbutton>
          <.tbutton bgg-color="bg-blue-200">
            default
          </.tbutton>

          <.cbutton>
            default
          </.cbutton>
          <.cbutton bgr_color='red'>
            color
          </.cbutton>
          <.cbutton bgr_color='red' class="w-full">
            many w tailwind
          </.cbutton>
          <.cbutton bgr_color='red' style="color:blue;">
            many w styled
          </.cbutton>
          <.cbutton>
            class vs styled
          </.cbutton>


      </div>
    </div>
    """
  end

end
