defmodule Excalt.Vcard.Parser do
  @moduledoc """
  Parses XML string strings from response.
  """

  def parse_addressbooks(xml_response) do
    Saxy.parse_string(xml_response, Excalt.Vcard.AddressbookHandler, {nil, []})
  end

  def parse_contacts_from_addressbook(xml_response) do
    Saxy.parse_string(xml_response, Excalt.Vcard.ContactHandler, {nil, []})
  end


end
