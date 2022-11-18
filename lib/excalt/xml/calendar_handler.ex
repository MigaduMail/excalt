defmodule Excalt.XML.CalendarHandler do
  @moduledoc nil

  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, {_current_tag, calendars}) do
    {:ok, calendars}
  end

  def handle_event(:start_element, {tag_name, attributes}, {_current_tag, calendars}) do
    calendars =
      if String.match?(tag_name, ~r/comp$/) do
        {"name", attr_name} = List.first(attributes)
        [current_calendar | calendars] = calendars
        current_calendar = Map.put(current_calendar, :type, attr_name)
        [current_calendar | calendars]
      else
        calendars
      end

    if String.match?(tag_name, ~r/response$/) do
      calendars = [%Excalt.Calendar{} | calendars]
      {:ok, {tag_name, calendars}}
    else
      {:ok, {tag_name, calendars}}
    end
  end

  def handle_event(:end_element, _, state) do
    {:ok, state}
  end

  def handle_event(:characters, content, {current_tag, calendars}) do
    calendars =
      if String.match?(current_tag, ~r/href/) and String.length(String.trim(content)) > 0 do
        [current_calendar | calendars] = calendars
        current_calendar = Map.put(current_calendar, :url, content)
        [current_calendar | calendars]
      else
        calendars
      end

    calendars =
      if String.match?(current_tag, ~r/displayname/) and String.length(String.trim(content)) > 0 do
        [current_calendar | calendars] = calendars
        current_calendar = Map.put(current_calendar, :name, content)
        [current_calendar | calendars]
      else
        calendars
      end

    calendars =
      if String.match?(current_tag, ~r/supported-calendar-component-set/) do
        [current_calendar | calendars] = calendars
        current_calendar = Map.put(current_calendar, :type, String.trim(content))

        [current_calendar | calendars]
      else
        calendars
      end

    calendars =
      if String.match?(current_tag, ~r/calendar-timezone/) and String.match?(content, ~r/BEGIN/) do
        [current_calendar | calendars] = calendars
        current_calendar = Map.put(current_calendar, :timezone, content)

        [current_calendar | calendars]
      else
        calendars
      end

    {:ok, {current_tag, calendars}}
  end
end
