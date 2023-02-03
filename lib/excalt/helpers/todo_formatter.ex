defmodule Excalt.Helpers.TodoFormatter do
  @moduledoc """
  Helpers to format a list of todos as returned and parsed by Excalt.Todo.
  """

  @doc """
  Formats the list of todos into human-readable format.
  The input is a list of todos as returned from Excalt.Todo.parsed_list!/4.
  If exclude_completed is true, only the not yet completed todos are being shown.
  """
  @spec formatted_txt(
          todos :: [Excalt.Todo.t()],
          exclude_completed :: Boolean.t()
        ) :: String.t()
  def formatted_txt(todos, exclude_completed \\ false) do
    todos =
      if exclude_completed do
        Enum.filter(todos, fn todos ->
          todo = List.first(todos)
          completed = Naiveical.Extractor.extract_contentline_by_tag(todo, "completed")
          is_nil(completed)
        end)
      else
        todos
      end

    "Todos\n" <>
      Enum.reduce(todos, "", fn todos, acc ->
        todo = List.first(todos)

        {_tag, attrs, summary_str} =
          Naiveical.Extractor.extract_contentline_by_tag(todo, "SUMMARY")

        {_tag, attrs, description_str} =
          Naiveical.Extractor.extract_contentline_by_tag(todo, "DESCRIPTION")

        due_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(todo, "dtstart")

        acc <>
          Timex.format!(due_date, "%d-%b-%Y %H:%M", :strftime) <>
          " #{summary_str} (#{description_str})\n"
      end)
  end
end
