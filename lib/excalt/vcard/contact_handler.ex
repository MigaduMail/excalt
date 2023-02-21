defmodule Excalt.Vcard.ContactHandler do
  @moduledoc """
  Parser Handler for Vcard contacts
  """

  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, {_xml_tag, contacts}) do
    {:ok, contacts}
  end

  def handle_event(:start_element, {xml_el, _attributes}, {_current_tag, contacts}) do
    contacts = handle_contacts(contacts, xml_el, ~r/response/)

    {:ok, {xml_el, contacts}}
  end

  def handle_event(:characters, content, {current_tag, contacts}) do
    content = String.trim(content)

    contacts =
      contacts
      |> handle_contacts(current_tag, ~r/href/, :url, content)
      |> handle_contacts(current_tag, ~r/getetag/, :etag, content)
      |> handle_contacts(current_tag, ~r/address-data/, :vcard_raw, content)

    {:ok, {current_tag, contacts}}
  end

  def handle_event(:end_element, _, contacts) do
    {:ok, contacts}
  end

  def handle_contacts(contacts, xml_el, ~r/response/ = regex) do
    if String.match?(xml_el, regex) do
      [%Excalt.Vcard.Contact{} | contacts]
    else
      contacts
    end
  end

  def handle_contacts(contacts, xml_el, regex, field, content) do
    has_element = String.match?(xml_el, regex)
    handle_contacts(contacts, field, has_element, content)
  end

  def handle_contacts(contacts, _field, true, content) when length(content) < 0, do: contacts
  def handle_contacts(contacts, _field, false, _content), do: contacts

  def handle_contacts([current_contact | contacts], field, true, content) do
    contact = Map.put(current_contact, field, content)
    [contact | contacts]
  end
end
