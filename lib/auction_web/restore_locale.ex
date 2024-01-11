defmodule AuctionWeb.RestoreLocale do
  def on_mount(:default, %{"locale" => locale}, _session, socket) do
    Gettext.put_locale(AuctionWeb.Gettext, locale)
    {:cont, socket}
  end

  # catch-all case
  def on_mount(:default, _params, _session, socket), do: {:cont, socket}
end
