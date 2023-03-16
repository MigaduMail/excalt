defmodule Excalt.Vcard.ReqBuilderTest do
  use ExUnit.Case, async: true


  test "List all addressbooks" do
    expected =
      """
      <?xml version="1.0"?>
      <D:propfind xmlns:D="DAV:" xmlns:card="urn:ietf:params:xml:ns:carddav">
      <D:prop>
      <D:displayname>
      </D:displayname>
      <card:addressbook-description>
      </card:addressbook-description>
      <card:supported-address-data>
      </card:supported-address-data>
      </D:prop>
      </D:propfind>
      """
      |> String.replace("\n", "")

    assert expected == Excalt.Vcard.ReqBuilder.list_all_addressbooks()
  end

  test "Get contacts from addressbook" do
    expected =
      """
      <card:addressbook-query xmlns:D="DAV:" xmlns:card="urn:ietf:params:xml:ns:carddav">
      <D:prop>
      <card:address-data>
      </card:address-data>
      <D:getetag>
      </D:getetag>
      </D:prop>
      </card:addressbook-query>
      """
      |> String.replace("\n", "")

    assert expected == Excalt.Vcard.ReqBuilder.get_contacts_from_addressbook()
  end

  test "Get single contact by url" do
    expected =
      """
      <card:addressbook-multiget xmlns:D="DAV:" xmlns:card="urn:ietf:params:xml:ns:carddav">
      <D:href>
      /addressbooks/test@email.com/contacts/abc-def-fez-123454657.vcf
      </D:href>
      <D:prop>
      <card:address-data>
      </card:address-data>
      <D:getetag>
      </D:getetag>
      </D:prop>
      </card:addressbook-multiget>
      """
      |> String.replace("\n", "")

    assert expected ==
             Excalt.Vcard.ReqBuilder.get_contact(
               "/addressbooks/test@email.com/contacts/abc-def-fez-123454657.vcf"
             )
  end

  test "Get multiple contacts by urls" do
    urls = [
      "/addressbooks/test@email.com/contacts/abc-def-fez-123454657.vcf",
      "/addressbooks/test@email.com/contacts/abc-def-fez-000000000.vcf",
      "/addressbooks/test@email.com/contacts/abc-def-fez-100000000.vcf",
      "/addressbooks/test@email.com/contacts/abc-def-fez-120000000.vcf"
    ]
    |> Enum.reverse()

    expected = """
    <card:addressbook-multiget xmlns:D="DAV:" xmlns:card="urn:ietf:params:xml:ns:carddav">
    <D:href>
    /addressbooks/test@email.com/contacts/abc-def-fez-123454657.vcf
    </D:href>
    <D:href>
    /addressbooks/test@email.com/contacts/abc-def-fez-000000000.vcf
    </D:href>
    <D:href>
    /addressbooks/test@email.com/contacts/abc-def-fez-100000000.vcf
    </D:href>
    <D:href>
    /addressbooks/test@email.com/contacts/abc-def-fez-120000000.vcf
    </D:href>
    <D:prop>
    <card:address-data>
    </card:address-data>
    <D:getetag>
    </D:getetag>
    </D:prop>
    </card:addressbook-multiget>
    """
    |> String.replace("\n", "")

    assert expected == Excalt.Vcard.ReqBuilder.get_contacts(urls)
  end
end
