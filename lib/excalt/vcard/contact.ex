defmodule Excalt.Vcard.Contact do
  @moduledoc """
  Single Vcard contact
  """

  defstruct etag: nil, url: nil, vcard_raw: nil

  def get(server_url, username, password, addressbook, contact_url) do
    authentication = Excalt.Vcard.Addressbook.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook)
    req_body = Excalt.Vcard.ReqBuilder.get_contact(contact_url)
    req_header = [authentication, {"Depth", "1"}]
    request = Finch.build("REPORT", req_url, req_header, req_body)

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 207, body: body}} ->
        [contact] = Excalt.Vcard.Parser.parse_contacts_from_addressbook(body)

      {:ok, %Finch.Response{status: 404, body: _}} ->
        {:error, :not_found}

      _ ->
        # implement more error handling
        :error
    end
  end


  def create(server_url, username, password, addressbook_name, vcf_text) do
    authentication = Excalt.Vcard.Addressbook.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    uuid = Elixir.UUID.uuid4
    req_url = "#{req_url}" <> "/" <> "#{uuid}.vcf"
    req_body = vcf_text


    request = Finch.build("PUT", req_url, [authentication, {"If-None-Match", "*"}], req_body)

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 201, body: body}} ->
        {:ok, body}

      _ ->
        :error
    end
   end
 # Client need to change the whole vcard, no way of incremental changes: https://www.rfc-editor.org/rfc/rfc6352#section-9.1
  def update(server_url, username, password, addressbook_name, etag, contact_uuid, vcf_text) do
    authentication = Excalt.Vcard.Addressbook.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    req_url = "#{req_url}" <> "/" <> "#{contact_uuid}.vcf"
    IO.inspect(req_url: req_url)
    IO.inspect(etag: etag)
    req_body = vcf_text


    request = Finch.build("PUT", req_url, [authentication, {"Content-Type", "text/vcard"}], req_body)
    IO.inspect request
     case Finch.request(request, ExcaltFinch) do
       {:ok, %Finch.Response{status: 201, body: body}} ->
         {:ok, body}


       {:ok, %Finch.Response{status: 404, body: body}} ->
         {:error, :not_found}

       {:ok, %Finch.Response{status: status, body: body}} ->
         IO.inspect(status: status)
         IO.inspect(body: body)
     end
    end

  def delete(server_url, username, password, addressbook_name, contact_uuid) do
    authentication = Excalt.Vcard.Addressbook.build_authentication_header(username, password)
    req_url = Excalt.Vcard.UrlHelper.build_url(server_url, username, addressbook_name)
    req_url = "#{req_url}" <> "/" <> "#{contact_uuid}.vcf"

    request = Finch.build("DELETE", req_url, [authentication], "")

    case Finch.request(request, ExcaltFinch) do
      {:ok, %Finch.Response{status: 201, body: body}} ->
        {:ok, body}

      {:ok, %Finch.Response{status: 404, body: body}} ->
        {:error, :not_found}
    end
   end

  end
