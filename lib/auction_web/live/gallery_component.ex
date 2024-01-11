defmodule AuctionWeb.GalleryComponent do
  use AuctionWeb, :live_component

  def mount(socket) do

	  {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="swiper" id="swiper" phx-hook="Swiper">
      <%!-- <pre><%= inspect(assigns, pretty: true) %></pre> --%>
      <div style="--swiper-navigation-color: #fff; --swiper-pagination-color: #fff" class="swiper mySwiper2">
        <div class="swiper-wrapper">
          <%= for image <- @images do %>
            <div class="swiper-slide">
              <img src={~p"/uploads/#{image.image_filename}"} />
            </div>
          <% end %>
        </div>
        <div class="swiper-button-next"></div>
        <div class="swiper-button-prev"></div>
      </div>
      <div thumbsSlider="" class="swiper mySwiper">
        <div class="swiper-wrapper">
          <%= for image <- @images do %>
            <div class="swiper-slide">
              <img src={~p"/uploads/#{image.image_filename}"} />
            </div>
          <% end %>
        </div>
      </div>

    </div>
    """
  end

  # def render(assigns) do
  #   ~H"""
  #   <div class="swiper" phx-hook="Swiper" id="swiper" phx-update="ignore">
  #     <div class="swiper-wrapper">
  #       <img
  #                       :if={length(@tournament.field_photo_locations) < 1}
  #                       src={~p"/images/image_not_available.png"}
  #                       alt="image"
  #                     />
  #       <div
  #         :for={
  #           {field_photo_location, index} <-
  #             Enum.with_index(@tournament.field_photo_locations)
  #         }
  #         class="swiper-slide"
  #       >
  #         <img src={field_photo_location} alt="image" />
  #       </div>
  #     </div>
  #     <div class="swiper-pagination"></div>
  #     <div class="swiper-button-prev"></div>
  #     <div class="swiper-button-next"></div>
  #   </div>

  #   """
  # end
end
