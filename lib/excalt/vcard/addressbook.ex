defmodule Excalt.Vcard.Addressbook do
  @moduledoc """
  Fetching addressbooks from the carddav server
  """

  defstruct name: nil, url: nil, description: nil, content_types: [], versions: []

  @type t :: %__MODULE__{
          name: String.t(),
          url: String.t(),
          description: String.t(),
          content_types: List.t(),
          versions: List.t()
        }
  @doc """
  Getting all address books from the server.
  In most cases addressbooks are under url
  https://server_url/addressbooks/username/addressbook_name
  With PROPFIND method we query the server to list us all addresbooks
  """
  @spec get_all_addressbooks(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t()
        ) ::
          {:ok, [Excalt.Vcard.Addressbook.t()]} | {:error, any()}
  def get_all_addressbooks(server_url, username, password) do
    request_body = Excalt.Vcard.ReqBuilder.list_all_addressbooks()
    request_url = Excalt.Vcard.UrlHelper.build_url(server_url, username)
    auth_header = Excalt.Vcard.Helpers.build_authentication_header(username, password)

    request = Finch.build("PROPFIND", request_url, [auth_header], request_body)

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 207, body: xml_body}} ->
        Excalt.Vcard.Parser.parse_addressbooks(xml_body)

      {:ok, %Finch.Response{status: 401, body: _}} ->
        {:error, :wrong_credentials}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}
    end
  end

  @doc """
  Get a single addressbook with list of vcard contacts.
  Using REPORT method!
  addressbook is url resource server_url/addressbooks/username/addressbook_name
  this function is fetching all vcards from addressbook
  """
  @spec get_addressbook_contacts(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          addressbook_name :: String.t()
        ) ::
          {:ok, [Excalt.Vcard.Contact.t()]} | {:error, any()}
  def get_addressbook_contacts(server_url, username, password, addressbook_name) do
    auth_header = Excalt.Vcard.Helpers.build_authentication_header(username, password)

    request_header = [auth_header, {"Depth", "1"}]

    request_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    request_body = Excalt.Vcard.ReqBuilder.get_contacts_from_addressbook()
    request = Finch.build("REPORT", request_url, request_header, request_body)

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 207, body: xml_body}} ->
        Excalt.Vcard.Parser.parse_contacts_from_addressbook(xml_body)

      {:ok, %Finch.Response{status: 401, body: _body}} ->
        {:error, :wrong_credentials}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}
    end
  end
end
