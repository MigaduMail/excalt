# Read from the config file in your env.
# {
#   "server_url": "https://cdav.domain.com",
#   "username": "username"
#   "password": "password"
#   "addressbook_name": "addresbook_name"
# }

# TODO make to accept custom user args, if the config file not present
# args = System.argv()
# IO.inspect(args)

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

# Get all addressbooks urls

addressbooks =
  Excalt.Vcard.Addressbook.get_all_addressbooks(
    config.server_url,
    config.username,
    config.password
  )

IO.inspect(addressbooks: addressbooks)

# Getting addressbook contacts

addressbook_contacts =
  Excalt.Vcard.Addressbook.get_addressbook_contacts(
    config.server_url,
    config.username,
    config.password,
    config.addressbook_name
  )

IO.inspect(addressbook_contacts: addressbook_contacts)
