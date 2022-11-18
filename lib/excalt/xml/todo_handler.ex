defmodule Excalt.XML.TodoHandler do
  @moduledoc nil

  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, {_current_tag, todos}) do
    {:ok, todos}
  end

  def handle_event(:start_element, {tag_name, _attributes}, {_current_tag, todos}) do
    if String.match?(tag_name, ~r/response$/) do
      todos = [%Excalt.Todo{} | todos]
      {:ok, {tag_name, todos}}
    else
      {:ok, {tag_name, todos}}
    end
  end

  def handle_event(:end_element, _, state) do
    {:ok, state}
  end

  def handle_event(:characters, content, {current_tag, todos}) do
    todos =
      if String.match?(current_tag, ~r/href/) and String.length(String.trim(content)) > 0 do
        [current_todo | todos] = todos
        current_todo = Map.put(current_todo, :url, content)
        [current_todo | todos]
      else
        todos
      end

    todos =
      if String.match?(current_tag, ~r/getetag/) and String.length(String.trim(content)) > 0 do
        [current_todo | todos] = todos
        current_todo = Map.put(current_todo, :etag, content)
        [current_todo | todos]
      else
        todos
      end

    todos =
      if String.match?(current_tag, ~r/calendar-data/) and String.match?(content, ~r/BEGIN/) do
        [current_todo | todos] = todos
        current_todo = Map.put(current_todo, :icalendar, content)

        [current_todo | todos]
      else
        todos
      end

    {:ok, {current_tag, todos}}
  end
end
