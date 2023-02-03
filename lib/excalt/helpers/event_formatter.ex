defmodule Excalt.Helpers.EventFormatter do
  @moduledoc """
  Returns the filtered list of events containing only the events that start and end in the same day.
  The input is the list of events as returned by Excalt.Event.parsed_list!/6).
  """

  alias Naiveical.Extractor

  @spec intraday_events(events :: [String.t()]) :: [Excalt.Event.t()]
  @doc """
  Extracts all events having start and end within the same day. Returns a list of events.
  """
  def intraday_events(events) do
    events
    |> Enum.filter(fn e ->
      if is_nil(e.icalendar) do
        # Filter out empty icalendars
        false
      else
        # Keep only events where start and end is in the same day
        events = Naiveical.Extractor.extract_sections_by_tag(e.icalendar, "VEVENT")
        event = List.first(events)

        dtstart_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(event, "dtstart")
        dtend_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(event, "dtend")
        DateTime.to_date(dtstart_date) == DateTime.to_date(dtend_date)
      end
    end)
    |> Enum.sort(fn a, b ->
      a_events = Naiveical.Extractor.extract_sections_by_tag(a.icalendar, "VEVENT")
      a_event = List.first(a_events)
      b_events = Naiveical.Extractor.extract_sections_by_tag(b.icalendar, "VEVENT")
      b_event = List.first(b_events)

      a_dtstart_date =
        Naiveical.Extractor.extract_datetime_contentline_by_tag!(a_event, "dtstart")

      b_dtstart_date =
        Naiveical.Extractor.extract_datetime_contentline_by_tag!(b_event, "dtstart")

      a_dtstart_date > b_dtstart_date
    end)
  end

  @doc """
  Returns the filtered list of events containing only the events where the start and end are on a different day.
  The input is the list of events as returned by Excalt.Event.parsed_list!/6).
  """
  @spec multiday_events(events :: [Excalt.Event.t()]) :: {[Excalt.Event.t()], [Excalt.Event.t()]}
  def multiday_events(events) do
    events
    |> Enum.filter(fn e ->
      if is_nil(e.icalendar) do
        # Filter out empty icalendars
        false
      else
        events = Naiveical.Extractor.extract_sections_by_tag(e.icalendar, "VEVENT")
        event = List.first(events)

        dtstart_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(event, "dtstart")
        dtend_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(event, "dtend")

        dtstart_date != dtend_date
      end
    end)
    |> Enum.sort(fn a, b ->
      a_events = Naiveical.Extractor.extract_sections_by_tag(a.icalendar, "VEVENT")
      a_event = List.first(a_events)
      b_events = Naiveical.Extractor.extract_sections_by_tag(b.icalendar, "VEVENT")
      b_event = List.first(b_events)

      a_dtstart_date =
        Naiveical.Extractor.extract_datetime_contentline_by_tag!(a_event, "dtstart")

      a_dtend_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(a_event, "dtend")

      b_dtstart_date =
        Naiveical.Extractor.extract_datetime_contentline_by_tag!(b_event, "dtstart")

      b_dtend_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(b_event, "dtend")

      a_dtstart_date == b_dtstart_date
    end)
  end

  @doc """
  Extracts the basic information about a list of events, that is start-datetime, end-datetime, and the summary.
  """
  @spec basic_info(events :: [Excalt.Event.t()]) :: [{DateTime.t(), DateTime.t(), String.t()}]
  def basic_info(events) do
    Enum.map(events, fn e ->
      events = Naiveical.Extractor.extract_sections_by_tag(e.icalendar, "VEVENT")
      event = List.first(events)

      dtstart_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(event, "dtstart")
      dtend_date = Naiveical.Extractor.extract_datetime_contentline_by_tag!(event, "dtend")

      {_tag, attrs, summary_str} =
        Naiveical.Extractor.extract_contentline_by_tag(event, "SUMMARY")

      {dtstart_date, dtend_date, summary_str}
    end)
  end

  @doc """
  Formats the list of events by grouping them per day
  """
  @spec daily_grouping(events :: [Excalt.Event.t()]) :: [[Excalt.Event.t()]]
  def daily_grouping(events) do
    Enum.chunk_by(events, fn {dtstart_a, _, _} ->
      dtstart_a = DateTime.to_date(dtstart_a)
      dtstart_a
    end)
  end

  @doc """
  Formats the list of multiday-events into a human-readable text.
  """
  @spec multiday_txt(events :: [Excalt.Event.t()]) :: String.t()
  def multiday_txt(events) do
    multiday_events = events |> multiday_events |> basic_info

    "Multiday events\n" <>
      Enum.reduce(multiday_events, "", fn {dtstart, dtend, summary}, acc ->
        acc <>
          Timex.format!(dtstart, "  %d-%b-%Y", :strftime) <>
          " - " <>
          Timex.format!(dtend, "%d-%b-%Y", :strftime) <> " #{summary}\n"
      end)
  end

  @doc """
  Formats the list of intraday-events into a human-readable text.
  """
  @spec intraday_txt(events :: [Excalt.Event.t()]) :: String.t()
  def intraday_txt(events) do
    day_list = events |> intraday_events |> basic_info |> daily_grouping

    "Intraday events:\n" <>
      Enum.reduce(day_list, "", fn day, acc ->
        {day_date, _, _} = List.first(day)

        acc <>
          Timex.format!(day_date, "%a %d-%b-%Y", :strftime) <>
          if DateTime.to_date(day_date) == Date.utc_today(),
            do: " <- today",
            else:
              "" <>
                "\n" <>
                Enum.reduce(day, "", fn {dtstart, dtend, summary}, acc ->
                  acc <>
                    Timex.format!(dtstart, "  %H:%M", :strftime) <>
                    " - " <>
                    Timex.format!(dtend, "%H:%M", :strftime) <> " #{summary}\n"
                end)
      end)
  end
end
