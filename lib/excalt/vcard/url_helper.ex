defmodule Excalt.Vcard.UrlHelper do
  @moduledoc """
  Building url for carrdav requests.
  """

  def build_url(server_url, username) do
    username = URI.encode(username)

    "#{server_url}/addressbooks/#{username}"
  end


  def build_url(server_url, username, addressbook_name) do
    username = URI.encode(username)
    addressbook = URI.encode(addressbook_name)

    "#{server_url}/addressbooks/#{username}/#{addressbook}"
  end

end
