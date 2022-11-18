defmodule Excalt.XML.EventHandler do
  @moduledoc nil

  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, {_current_tag, events}) do
    {:ok, events}
  end

  def handle_event(:start_element, {tag_name, _attributes}, {_current_tag, events}) do
    if String.match?(tag_name, ~r/response$/) do
      events = [%Excalt.Event{} | events]
      {:ok, {tag_name, events}}
    else
      {:ok, {tag_name, events}}
    end
  end

  def handle_event(:end_element, _, state) do
    {:ok, state}
  end

  def handle_event(:characters, content, {current_tag, events}) do
    events =
      if String.match?(current_tag, ~r/href/) and String.length(String.trim(content)) > 0 do
        [current_event | events] = events
        current_event = Map.put(current_event, :url, content)
        [current_event | events]
      else
        events
      end

    events =
      if String.match?(current_tag, ~r/getetag/) and String.length(String.trim(content)) > 0 do
        [current_event | events] = events
        current_event = Map.put(current_event, :etag, content)
        [current_event | events]
      else
        events
      end

    events =
      if String.match?(current_tag, ~r/calendar-data/) and String.match?(content, ~r/BEGIN/) do
        [current_event | events] = events
        current_event = Map.put(current_event, :icalendar, content)

        [current_event | events]
      else
        events
      end

    {:ok, {current_tag, events}}
  end
end
