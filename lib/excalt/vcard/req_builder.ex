defmodule Excalt.Vcard.ReqBuilder do
  @moduledoc """
  Building XML requests for the CARDDAV SERVER
  """

  # carrdav xml namespace "urn:ietf:params:xml:ns:carddav"
  # xml element type "DAV:"
  #

  @doc """
  Returns the urls of addressbooks with they
  """
  def list_all_addressbooks do
    Saxy.XML.element(
      "D:propfind",
      [
        "xmlns:D": "DAV:",
        "xmlns:card": "urn:ietf:params:xml:ns:carddav", # the card namespace is something that will be returned from the server in the response, so for clarity, we name it card also
      ],
      Saxy.XML.element("D:prop", [], [
            Saxy.XML.element("D:displayname", [], ""),
            Saxy.XML.element("card:addressbook-description", [], ""),
            Saxy.XML.element("card:supported-address-data", [], ""),
            Saxy.XML.element("cs:getctag", [], "")
          ])
    )
    |> Saxy.encode!([])
  end


  @doc """
  Return the xml with all the contacts in the addressbook.
  This response can be huge, so instead after initial sync we
  should only monitor etags for changes, and update/delete contacts on the client
  """
  def get_contacts_from_addressbook do
    Saxy.XML.element(
      "card:addressbook-query",
      [
        "xmlns:D": "DAV:",
        "xmlns:card": "urn:ietf:params:xml:ns:carddav"
      ],
      Saxy.XML.element("D:prop", [], [
            Saxy.XML.element("card:address-data", [], ""),
            Saxy.XML.element("D:getetag", [], "")
          ])
    )
    |> Saxy.encode!()
  end

  @doc """
  get a single contantact by url
  """
  def get_contact(contact_url) do
    Saxy.XML.element(
      "card:addressbook-multiget",
      [
        "xmlns:D": "DAV:",
        "xmlns:card": "urn:ietf:params:xml:ns:carddav"
      ],
      [
      Saxy.XML.element("D:href", [], contact_url),
      Saxy.XML.element("D:prop", [], [
            Saxy.XML.element("card:address-data", [], ""),
            Saxy.XML.element("D:getetag", [], "")
          ]),
      ]
    )
    |> Saxy.encode!()

  end

#  def get_contacts(multiple_urls) do

#  end
  end
