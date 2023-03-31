defmodule Excalt.HelpersTest do
  use ExUnit.Case, async: true

  @example_response_header [
    {"server", "nginx/1.14.0"},
    {"date", "Tue, 30 Mar 2023 10:00:00 GMT"},
    {"content-type", "application/xml; charset=utf-8"},
    {"transfer-encoding", "chunked"},
    {"connection", "keep-alive"},
    {"x-version", "4.0.3"},
    {"vary", "Brief,Prefer"},
    {"etag", "\"1234-56789-123456\""}
  ]

  test "Extract value from response header" do
    expected_server = "nginx/1.14.0"
    expected_vary = "Brief,Prefer"
    expected_etag = "\"1234-56789-123456\""

    assert Excalt.Helpers.Request.extract_from_header(@example_response_header, "server") ==
             expected_server

    assert Excalt.Helpers.Request.extract_from_header(@example_response_header, "vary") ==
             expected_vary

    assert Excalt.Helpers.Request.extract_from_header(@example_response_header, "etag") ==
             expected_etag
  end

  test "Extracting non existent header value should result in empty string" do
    assert Excalt.Helpers.Request.extract_from_header(@example_response_header, "value") == ""
    refute Excalt.Helpers.Request.extract_from_header(@example_response_header, "etag") == ""
  end
end
