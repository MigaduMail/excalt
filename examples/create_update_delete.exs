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

# from = DateTime.now!("Europe/Zurich")
# to = Timex.shift(from, weeks: 1)
# from = Timex.shift(to, weeks: -3)

vtodo_ics = """
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//apiserver//API Server DAV//EN
BEGIN:VTODO
UID:20070514T103211Z-123404@example.com
DTSTAMP:20221114T103211Z
DTSTART:20221114T110000Z
DUE:20221209T130000Z
SUMMARY:Submit Revised Text
PRIORITY:1
STATUS:NEEDS-ACTION
DESCRIPTION: The highly important text
  needs to be written and published.
END:VTODO
END:VCALENDAR
"""

vtodo_uuid = "20070514T103211Z-123404@example.com"

new_todo =
  Excalt.Todo.create(
    config.server_url,
    config.username,
    config.password,
    config.todo,
    vtodo_ics,
    vtodo_uuid
  )

IO.inspect(new_todo: new_todo)

# updated_ics = Naiveical.Modificator.change_value(vtodo_ics, "completed", "20070707T100000Z")
# IO.puts updated_ics
# updated_todo =
#   Excalt.Todo.update(
#     config.server_url,
#     config.username,
#     config.password,
#     config.todo,
#     vtodo_ics,
#     vtodo_uuid,
#     vtodo_etag
#   )

# Excalt.Todo.delete(config.server_url, config.username, config.password, config.todo, vtodo_uuid)
