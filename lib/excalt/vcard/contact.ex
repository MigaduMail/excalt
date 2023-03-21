defmodule Excalt.Vcard.Contact do
  @moduledoc """
  Module responsible for CRUD operations on Vcards
  """

  @type t :: %__MODULE__{
          etag: String.t(),
          url: String.t(),
          vcard_raw: String.t()
        }

  defstruct etag: nil, url: nil, vcard_raw: nil

  @doc """
  Gets a single contact data.
  """
  @spec get(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          addressbook :: String.t(),
          contanct_url :: String.t()
        ) :: {:ok, etag :: String.t(), contact :: Contact.t()} | {:error, :not_found} | :error
  def get(server_url, username, password, addressbook, contact_url) do
    authentication = Excalt.Vcard.Helpers.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook)
    req_body = Excalt.Vcard.ReqBuilder.get_contact(contact_url)
    req_header = [authentication, {"Depth", "1"}]
    request = Finch.build("REPORT", req_url, req_header, req_body)

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 207, body: body, headers: headers}} ->
        etag = Excalt.Helpers.Request.extract_from_header(headers, "etag")
        {:ok, [contact]} = Excalt.Vcard.Parser.parse_contacts_from_addressbook(body)
        {:ok, etag, contact}

      {:ok, %Finch.Response{status: 404, body: _}} ->
        {:error, :not_found}

      _ ->
        :error
    end
  end

  @doc """
  Creates a new contact, VCF text should be a valid VCARD text
  If the contact already exists, and we try to do multiple creation of the same contact, the response code 201 is returned but the etag is not changed.
  """
  @spec create(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          addressbook_name :: String.t(),
          vcf_text :: String.t()
        ) :: {:ok, etag :: String.t()} | {:error, any()}
  def create(server_url, username, password, addressbook_name, vcf_text) do
    authentication = Excalt.Vcard.Helpers.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    req_body = vcf_text
    contact_uuid = Elixir.UUID.uuid4()
    req_url = "#{req_url}/#{contact_uuid}.vcf"

    request =
      Finch.build(
        "PUT",
        req_url,
        [authentication, {"If-None-Match", "*"}, {"Content-Type", "text/vcard"}],
        req_body
      )

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 201, body: _body, headers: headers}} ->
        etag = Excalt.Helpers.Request.extract_from_header(headers, "etag")
        if etag == "" do
          {etag, contact} = get_changed_contact_raw(authentication, req_url)
          {:ok, etag, contact}
        else
          {:ok, etag}
        end

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}
    end
  end

  @doc """
  Updates a contact. Issues a PUT request with new vcf file([RFC 6352 Section 9.1](https://www.rfc-editor.org/rfc/rfc6352#section-9.1)), but we must be careful
  not to change the URL and UID of the contact, since it may confuse other clients.
  After the successful update if the server did not returned etag,we need to issue GET request
  to figure out how the server changed the contact.
  """
  @spec update(String.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
          {:ok, any()} | {:error, any()}
  def update(server_url, username, password, addressbook_name, etag, contact_url_id, vcf_text) do
    authentication = Excalt.Vcard.Helpers.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    req_url = "#{req_url}/#{contact_url_id}"

    request =
      Finch.build(
        "PUT",
        req_url,
        [authentication, {"If-Match", etag}, {"Content-type", "text/vcard"}],
        vcf_text
      )

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 204, body: _body, headers: headers}} ->
        etag = Excalt.Helpers.Request.extract_from_header(headers, "etag")
        # In case the server did not returned etag we need to fetch the
        # contact again to see how the server made changes.
        if etag == "" do
          {etag, contact} = get_changed_contact_raw(authentication, req_url)
          {:ok, etag, contact}
        else
          {:ok, etag}
        end

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}
    end
  end

  @doc """
  Deletes a contact from server.
  """
  @spec delete(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          addressbook_name :: String.t(),
          etag :: String.t(),
          contact_url_id :: String.t()
        ) :: {:ok, any()} | {:error, any()}
  def delete(server_url, username, password, addressbook_name, etag, contact_url_id) do
    authentication = Excalt.Vcard.Helpers.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    req_url = "#{req_url}/#{contact_url_id}"

    request = Finch.build("DELETE", req_url, [authentication, {"If-Match", etag}], "")

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 201, body: _body}} ->
        # Return etag to delete the contact from persistent storage.
        {:ok, etag}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        {:error, :not_found}
    end
  end

  @doc """
  Get only etags from server.
  """
  @spec get_etags(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          addressbook_name :: String.t()
        ) :: [String.t()] | []
  def get_etags(server_url, username, password, addressbook_name) do
    authentication = Excalt.Vcard.Helpers.build_authentication_header(username, password)
    request_headers = [authentication, {"Depth", "1"}]
    request_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)

    request_body = Excalt.Vcard.ReqBuilder.get_etags()

    request = Finch.build("REPORT", request_url, request_headers, request_body)

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 207, body: xml_body}} ->
        {:ok, contacts} = Excalt.Vcard.Parser.parse_contacts_from_addressbook(xml_body)
        Enum.map(contacts, & &1.etag)

      _ ->
        []
    end
  end

  @spec get_changed_contact_raw(auth :: String.t(), req_url :: String.t()) ::
          {String.t(), String.t()} | {nil, nil}
  defp get_changed_contact_raw(auth, req_url) do
    response =
      Finch.build(:get, req_url, [auth, {"Depth", "1"}], "")
      |> Finch.request(ExcaltFinch)

    case response do
      {:ok, %Finch.Response{status: 200, body: updated_vcard, headers: headers}} ->
        etag = Excalt.Helpers.Request.extract_from_header(headers, "etag")
        {etag, updated_vcard}

      {:ok, %Finch.Response{status: _, body: ""}} ->
        {nil, nil}
    end
  end
end
