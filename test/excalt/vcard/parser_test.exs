defmodule Excalt.Vcard.ParserTest do
  use ExUnit.Case, async: true

  describe "Addressbooks" do
    test "Parse single addressbook from server response" do
      response = """
      <?xml version="1.0" encoding="utf-8"?>
      <d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
      <d:response>
      <d:href>/addressbooks/test@email.com/business/</d:href>
      <d:propstat>
      <d:prop>
        <d:displayname>Business</d:displayname>
        <card:supported-address-data>
          <card:address-data-type content-type="text/vcard" version="3.0"/>
          <card:address-data-type content-type="text/vcard" version="4.0"/>
          <card:address-data-type content-type="application/vcard+json" version="4.0"/>
        </card:supported-address-data>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
      </d:propstat>
      </d:response>
      </d:multistatus>
      """

      parsed_response = Excalt.Vcard.Parser.parse_addressbooks(response)

      expected = [
        %Excalt.Vcard.Addressbook{
          name: "Business",
          url: "/addressbooks/test@email.com/business/",
          description: nil,
          content_types: ["application/vcard+json", "text/vcard", "text/vcard"],
          versions: ["4.0", "4.0", "3.0"]
        }
      ]

      assert {:ok, expected} == parsed_response
    end

    test "Parse multiple addressbooks from server response" do
      response =
        """
        <?xml version="1.0"?>
        <d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
        <d:response>
        <d:href>/addressbooks/test@email.com/</d:href>
        <d:propstat>
        <d:prop>
          <d:displayname/>
          <card:addressbook-description/>
          <card:supported-address-data/>
        </d:prop>
        <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
        </d:response>
        <d:response>
        <d:href>/addressbooks/test@email.com/business/</d:href>
        <d:propstat>
        <d:prop>
          <d:displayname>Business</d:displayname>
          <card:supported-address-data>
            <card:address-data-type content-type="text/vcard" version="3.0"/>
            <card:address-data-type content-type="text/vcard" version="4.0"/>
            <card:address-data-type content-type="application/vcard+json" version="4.0"/>
          </card:supported-address-data>
        </d:prop>
        <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
        <d:prop>
          <card:addressbook-description/>
        </d:prop>
        <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
        </d:response>
        <d:response>
        <d:href>/addressbooks/test@email.com/family/</d:href>
        <d:propstat>
        <d:prop>
          <d:displayname>Family</d:displayname>
          <card:supported-address-data>
            <card:address-data-type content-type="text/vcard" version="3.0"/>
            <card:address-data-type content-type="text/vcard" version="4.0"/>
            <card:address-data-type content-type="application/vcard+json" version="4.0"/>
          </card:supported-address-data>
        </d:prop>
        <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        <d:propstat>
        <d:prop>
          <card:addressbook-description/>
        </d:prop>
        <d:status>HTTP/1.1 404 Not Found</d:status>
        </d:propstat>
        </d:response>
        </d:multistatus>
        """
        |> Excalt.Vcard.Parser.parse_addressbooks()

      {:ok, response} = response

      expected = [
        %Excalt.Vcard.Addressbook{
          name: "Family",
          description: nil,
          url: "/addressbooks/test@email.com/family/",
          content_types: ["application/vcard+json", "text/vcard", "text/vcard"],
          versions: ["4.0", "4.0", "3.0"]
        },
        %Excalt.Vcard.Addressbook{
          name: "Business",
          description: nil,
          url: "/addressbooks/test@email.com/business/",
          content_types: ["application/vcard+json", "text/vcard", "text/vcard"],
          versions: ["4.0", "4.0", "3.0"]
        },
        %Excalt.Vcard.Addressbook{
          name: nil,
          description: nil,
          url: "/addressbooks/test@email.com/",
          content_types: [],
          versions: []
        }
      ]

      assert Enum.sort(response) == Enum.sort(expected)
    end
  end

  describe "Contacts" do
    test "Parse contacts from addressbook" do
      response = """
      <?xml version="1.0" ?>
      <D:multistatus xmlns:D="DAV:"
                  xmlns:C="urn:ietf:params:xml:ns:carddav">
      <D:response>
       <D:href>/home/bernard/addressbook/vcf102.vcf</D:href>
       <D:propstat>
         <D:prop>
           <D:getetag>"23ba4d-ff11fb"</D:getetag>
           <C:address-data>BEGIN:VCARD
      VERSION:3.0
      NICKNAME:me
      UID:34222-232@example.com
      FN:Cyrus Daboo
      EMAIL:daboo@example.com
      END:VCARD
      </C:address-data>
         </D:prop>
         <D:status>HTTP/1.1 200 OK</D:status>
       </D:propstat>
      </D:response>
      <D:response>
       <D:href>/home/bernard/addressbook/vcf1.vcf</D:href>
       <D:status>HTTP/1.1 404 Resource not found</D:status>
      </D:response>
      </D:multistatus>
      """

      parsed_response = Excalt.Vcard.Parser.parse_contacts_from_addressbook(response)

      expected =
        [
          %Excalt.Vcard.Contact{
            url: "/home/bernard/addressbook/vcf102.vcf",
            etag: "\"23ba4d-ff11fb\"",
            vcard_raw:
              "BEGIN:VCARD\nVERSION:3.0\nNICKNAME:me\nUID:34222-232@example.com\nFN:Cyrus Daboo\nEMAIL:daboo@example.com\nEND:VCARD"
          },
          %Excalt.Vcard.Contact{
            url: "/home/bernard/addressbook/vcf1.vcf",
            etag: nil,
            vcard_raw: nil
          }
        ]
        |> Enum.sort()

      assert {:ok, expected} == parsed_response
    end
  end
end
