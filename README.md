# Excalt: Another CalDav client

Excalt allows you to communicate with a CalDav server using the xml structure as specified in ([RFC 4791](https://tools.ietf.org/html/rfc4791)).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `excalt` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:excalt, "~> 0.1.0"}
  ]
end
```
Then run `mix deps.get` to install the package and its dependencies.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/excalt>.

## Documentation

Available at [HexDocs](https://hexdocs.pm/excalt).

## Examples
``` elixir
calendars = Excalt.Calendar.list_raw "https://mycaldavserver.org", "myusername", "mypassword"
```

`

## VTIMEZONE database
The VTIMEZONE database has been compiled by using the [vzic utility](https://github.com/libical/vzic).

## Acknowledgments
A big help to build this library was the other elixir caldav client, ([caldav_client](https://github.com/software-mansion-labs/elixir-caldav-client). It has a slightly different scope, as it is focused on events, while this library also allows the manipulation of other resources.
