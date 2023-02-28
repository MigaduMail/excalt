defmodule Excalt.Vcard.AddressbookTest do
  use ExUnit.Case, async: true
  alias Excalt.Vcard.Addressbook
  # We are going to use test config
  # from file in the examples to test requests to addressbooks
  setup do
    config =
      Path.expand("examples/vcard/config.json") |> File.read!() |> Jason.decode!(keys: :atoms)

    {:ok, config: config}
  end

  describe "Addressbook PROPFIND requests" do
    test "Make call to get all available addressbok resources", %{config: config} do
      {status, response} =
        Addressbook.get_all_addressbooks(config.server_url, config.username, config.password)

      [single_addressbook | _rest] = response

      assert is_struct(single_addressbook, Addressbook)

      assert status == :ok
      assert is_list(response)
    end

    test "Wrong credentials to server", %{config: config} do
      {status, response} = Addressbook.get_all_addressbooks(config.server_url, "", "password")

      assert status == :error
      assert response == :wrong_credentials
    end

    test "User principal not found", %{config: config} do
      response =
        Addressbook.get_all_addressbooks(config.server_url, "test@example.com", "password")

      assert {:error, :not_found} == response
    end
  end

  describe "Addressbook REPORT requests" do
    # new user always have family and business addressbooks by default
    test "Get contacts from family addressbook", %{config: config} do
      {status, response} =
        Addressbook.get_addressbook_contacts(
          config.server_url,
          config.username,
          config.password,
          "family"
        )

      assert status == :ok
      refute Enum.empty?(response)
      assert is_list(response)
    end

    test "Get contacts from business addressbook", %{config: config} do
      {status, response} =
        Addressbook.get_addressbook_contacts(
          config.server_url,
          config.username,
          config.password,
          "business"
        )

      assert status == :ok
      refute Enum.empty?(response)
      assert is_list(response)
    end

    test "Get contacts from example addressbook", %{config: config} do
      {status, response} =
        Addressbook.get_addressbook_contacts(
          config.server_url,
          config.username,
          config.password,
          "example"
        )

      assert status == :error
      assert response == :not_found
      refute is_list(response)
    end

    test "Wrong credentials", %{config: config} do
      response =
        Addressbook.get_addressbook_contacts(
          config.server_url,
          config.username,
          "#{Elixir.UUID.uuid1()}",
          "family"
        )

      assert {:error, :wrong_credentials} == response
    end
  end
end
