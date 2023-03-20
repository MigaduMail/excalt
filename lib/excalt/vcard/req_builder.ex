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
        # the card namespace is something that will be returned from the our server in the response, so for clarity, we name it card also
        "xmlns:card": "urn:ietf:params:xml:ns:carddav"
      ],
      Saxy.XML.element("D:prop", [], [
        Saxy.XML.element("D:displayname", [], ""),
        Saxy.XML.element("card:addressbook-description", [], ""),
        Saxy.XML.element("card:supported-address-data", [], "")
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
  get a single contantact by providing url from the list of contacts from the addressbook
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
        ])
      ]
    )
    |> Saxy.encode!()
  end

  # Expect multiple urls in a form of list of strings
  # e.g. ["url1", "url2", "url3"]
  def get_contacts(multiple_urls) do
    xhref_elements = build_multiple_xml_href_elements(multiple_urls)

    xml_elements =
      [
        Saxy.XML.element("D:prop", [], [
          Saxy.XML.element("card:address-data", [], ""),
          Saxy.XML.element("D:getetag", [], "")
        ])
      ]
      |> append_urls_to_elements(xhref_elements)

    Saxy.XML.element(
      "card:addressbook-multiget",
      [
        "xmlns:D": "DAV:",
        "xmlns:card": "urn:ietf:params:xml:ns:carddav"
      ],
      xml_elements
    )
    |> Saxy.encode!()
  end

  @doc """
  Getting only etags from the server and comparing to one we
  already have can save us a ton of bandwith. The server should return the
  response off all etags and urls from the addressbook, so we can compare which
  of them are created/updated/deleted by other clients, and we can update our
  local addressbook with newest changes.
  """
  def get_etags() do
    Saxy.XML.element(
      "card:addressbook-query",
      [
        "xmlns:D": "DAV:",
        "xmlns:card": "urn:ietf:params:xml:ns:carddav"
      ],
      Saxy.XML.element("D:prop", [], [
        Saxy.XML.element("D:getetag", [], "")
      ])
    )
    |> Saxy.encode!()
  end

  defp build_multiple_xml_href_elements(urls) do
    Enum.map(urls, fn url -> Saxy.XML.element("D:href", [], url) end)
  end

  defp append_urls_to_elements(elements, []), do: elements

  defp append_urls_to_elements(elements, [url | rest]) do
    [url | elements]
    |> append_urls_to_elements(rest)
  end
end
