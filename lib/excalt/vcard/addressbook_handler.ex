defmodule Excalt.Vcard.AddressbookHandler do
  @moduledoc """
  Handler for parsing the addressbooks from the server.
  """

  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, addressbooks) do
    {:ok, addressbooks}
  end

  def handle_event(:end_document, _, {_current_xml_tag, addressbooks}) do
    {:ok, addressbooks}
  end


  def handle_event(:start_element, {xml_element, attributes}, {_current_xml_el, addressbooks}) do
    addressbooks =
      if String.match?(xml_element, ~r/response/) do
        [%Excalt.Vcard.Addressbook{} | addressbooks]
      else
        addressbooks
      end

    addressbooks =
      if String.match?(xml_element, ~r/address-data-type/) do
        [current_addressbook | addressbooks] = addressbooks
        [content_type, version] = attributes
        {"content-type", content_type} = content_type
        {"version", version} = version

        current_addressbook =
          append_content_type_and_version(current_addressbook, content_type, version)

        [current_addressbook | addressbooks]
      else
        addressbooks
      end

    {:ok, {xml_element, addressbooks}}
  end

  def handle_event(:end_element, _, addressbooks) do
    {:ok, addressbooks}
  end

  def handle_event(:characters, content, {current_tag, addressbooks}) do
    content = String.trim(content)
    addressbooks = update_current_addressbook(current_tag, ~r/href/, :url, addressbooks, content)

    addressbooks =
      update_current_addressbook(current_tag, ~r/displayname/, :name, addressbooks, content)

    addressbooks =
      update_current_addressbook(
        current_tag,
        ~r/addressbook-description/,
        :description,
        addressbooks,
        content
      )

    {:ok, {current_tag, addressbooks}}
  end

  @doc """
  Updates current addressbooks based on the if xml_element exists.
  """
  @spec update_current_addressbook(boolean(), atom(), List.t(), String.t()) ::
          [] | [Excalt.Vcard.Addressbook.t()]
  def update_current_addressbook(current_tag, regex, field, addressbooks, content) do
    String.match?(current_tag, regex) |> update_current_addressbook(field, addressbooks, content)
  end

  def update_current_addressbook(false, _field, addressbooks, _content), do: addressbooks

  def update_current_addressbook(
        true,
        field,
        [current_addressbook | addressbooks] = all_addressbooks,
        content
      ) do
    if String.length(content) <= 0 do
      all_addressbooks
    else
      updated_addressbook = Map.put(current_addressbook, field, content)
      [updated_addressbook | addressbooks]
    end
  end

  @doc """
  Add content types and versions to parsed addressbooks.
  """
  def append_content_type_and_version(
        %Excalt.Vcard.Addressbook{content_types: content_types, versions: versions} =
          current_addressbook,
        content_type,
        version
      ) do
    %{
      current_addressbook
      | content_types: [content_type | content_types],
        versions: [version | versions]
    }
  end
end
