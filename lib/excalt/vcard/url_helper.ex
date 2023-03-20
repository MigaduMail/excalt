defmodule Excalt.Vcard.UrlHelper do
  @moduledoc """
  Building urls for carrdav requests.
  """

  @spec build_url(server_url :: String.t(), username :: String.t()) :: String.t()
  def build_url(server_url, username) do
    username = URI.encode(username)

    "#{server_url}/addressbooks/#{username}"
  end

  @spec build_url(server_url :: String.t(), username :: String.t(), addressbook_name :: String.t()) :: String.t()
  def build_url(server_url, username, addressbook_name) do
    username = URI.encode(username)
    addressbook = URI.encode(addressbook_name)

    "#{server_url}/addressbooks/#{username}/#{addressbook}"
  end
end
