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

from = DateTime.now!("Europe/Zurich")
to = Timex.shift(from, weeks: 1)
from = Timex.shift(to, weeks: -3)

events =
  Excalt.Event.parsed_list!(
    config.server_url,
    config.username,
    config.password,
    config.calendar,
    from,
    to
  )

IO.puts(
  "Calendar from #{Timex.format!(from, "%a %d-%b-%Y", :strftime)} to #{Timex.format!(to, "%a %d-%b-%Y", :strftime)}"
)

multiday_txt = Excalt.Helpers.EventFormatter.multiday_txt(events)
IO.puts(multiday_txt)
intraday_txt = Excalt.Helpers.EventFormatter.intraday_txt(events)
IO.puts(intraday_txt)

todos =
  Excalt.Todo.parsed_list!(
    config.server_url,
    config.username,
    config.password,
    config.todo
  )

todo_txt = Excalt.Helpers.TodoFormatter.formatted_txt(todos, true)
IO.puts(todo_txt)
