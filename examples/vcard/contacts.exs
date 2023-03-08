# Examples of usage  CRUD for contacts
config =
  "~/.config/excalt/vcard_config.json"
  |> Path.expand()
  |> File.read()
  |> case do
    {:ok, content} ->
      Jason.decode!(content, keys: :atoms)

    {:error, _reason} ->
      raise "config file not found"
      # %{server_url: nil, username: nil, password: nil, addressbook_name: nil}
  end

# Contact creation

contact_vcf = """
BEGIN:VCARD
VERSION:4.0
UID:4fbe8971-0bc3-424c-9c26-36c3e1eff6b1
FN;PID=1.1:J.Doe
N:Doe;J.;;;
EMAIL;PID=1.1:jdoe@example.com
END:VCARD
"""

new_contact =
  Excalt.Vcard.Contact.create(
    config.server_url,
    config.username,
    config.password,
    config.addressbook_name,
    contact_vcf
  )
# Here in the inspect we should show
# the vcard raw itself and extract the uid and url for later
IO.inspect(created_contact: new_contact)


contact_uid = "4fbe8971-0bc3-424c-9c26-36c3e1eff6b1"

u_contact_vcf = """
BEGIN:VCARD
VERSION:4.0
UID:4fbe8971-0bc3-424c-9c26-36c3e1eff6b1
FN;PID=1.1:J.Doe
N:Doe;J.;;;
EMAIL;PID=1.1:new_mail@new_example.com
END:VCARD
"""

update_contact =
  Excalt.Vcard.Contact.update(
    config.server_url,
    config.username,
    config.password,
    config.addressbook_name,
    "etag",
    contact_uid,
    u_contact_vcf
  )

IO.inspect(updated_contact: update_contact)
