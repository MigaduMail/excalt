defmodule Excalt.Vcard.AddressbookHandler do
  @moduledoc """
  Handler for parsing the addressbooks from the server.
  """

  @behaviour Saxy.Handler

  # when we start document parsing the state is an empty list
  # in this case it will be populated at the end with addressbooks
  def handle_event(:start_document, _prolog, addressbooks) do
    {:ok, addressbooks}
  end

  def handle_event(:end_document, _, {_current_xml_tag, addressbooks}) do
    {:ok, addressbooks}
  end

  # from the xml response we need to get
  # href -> as url for the addressbook, the addressbook is missing
  # if the <d:status> el  of the response is 404 not found
  # displayname -> addressbook name on server | check if exists
  # addressbook-description -> short addressbook description | check if exists
  # supported-address-data -> can be a list of all supported server side vcards, if exists then we should also collect address-data-type in a list
  #
  #
  #

  def handle_event(:start_element, {xml_element, attributes}, {_current_xml_el, addressbooks}) do
    # String.match?(tag_name, ~r/response$/)
    addressbooks =
      if String.match?(xml_element, ~r/response/) do
        # by returning this, we init an empty addressbook struct so we can
        # populate it with related fields
        [%Excalt.Vcard.Addressbook{} | addressbooks]
      else
        addressbooks
      end

    # Extract content types and version
    # Who knows we might need it later on.
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

  # Do things within the element <el> content </el>
  def handle_event(:characters, content, {current_tag, addressbooks}) do
    # With each element we need to take care to pass already all
    # addressbooks or it will be overwritten
    # take care
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

    # return all new and updated addressbooks
    #
    {:ok, {current_tag, addressbooks}}
  end

  @doc """
  Updates current addressbooks based on the if xml_element exists.
  """
  @spec update_current_addressbook(boolean(), atom(), List.t(), String.t()) ::
          [] | [%Excalt.Vcard.Addressbook{}]
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
