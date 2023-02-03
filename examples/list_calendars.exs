#!/usr/bin/env elixir

# Read config, which should have the format:
# {
#  "server_url": "https://cdav.mydomain.com",
#  "username": "meandmyself",
#  "password": "mypassword",
#  "calendar": "work"
# }

config =
  "~/.config/excalt/config.json" |> Path.expand() |> File.read!() |> Jason.decode!(keys: :atoms)

cals = Excalt.Calendar.list!(
    config.server_url,
    config.username,
    config.password)


IO.inspect cals
