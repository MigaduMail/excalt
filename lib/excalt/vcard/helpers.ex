defmodule Excalt.Vcard.Helpers do
  @moduledoc """
  Helper functions
  """
  @doc """
  Build basic authentication header with encoded username and password.
  """
  @spec build_authentication_header(username :: String.t(), password :: String.t()) ::
          {String.t(), auth :: String.t()}
  def build_authentication_header(username, password) do
    encoded_auth = "#{username}:#{password}" |> Base.encode64()
    auth = "Basic " <> encoded_auth

    {"Authorization", auth}
  end

  @doc """
  Returns the last part of the contact url.
  ## Example
    contact url = /addressbook/test@email.com/contacts/abc-def-1234.vcf

  In the update of contact we need only the last part "abc-def-1234.vcf"
  This part should not be subject to change, since it can confuse other clients.
  """
  @spec extract_url_id(contact_url :: String.t()) :: String.t()
  def extract_url_id(contact_url) do
    contact_url
    |> String.split("/")
    |> List.last()
  end
end
