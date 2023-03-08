defmodule Excalt.Vcard.Helpers do
  @doc """
  Build basic authentication header with encoded username and password.
  """
  def build_authentication_header(username, password) do
    encoded_auth = "#{username}:#{password}" |> Base.encode64()
    auth = "Basic " <> encoded_auth

    {"Authorization", auth}
  end
end
