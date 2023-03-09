defmodule Excalt.Vcard.HelpersTest do
  use ExUnit.Case, async: true

  describe "Auth" do
    test "Header tuple" do
      username = "some_username"
      password = "password123"
      encoded = "#{username}:#{password}" |> Base.encode64()

      actual = Excalt.Vcard.Helpers.build_authentication_header(username, password)

      expected = {"Authorization", "Basic #{encoded}"}

      assert actual == expected
    end
   end
end
