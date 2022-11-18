defmodule Excalt.XML.Parser do
  @moduledoc """
  Parses the xml responses from the CalDav server.
  """

  @doc """
  Parse the list of events returned by the caldav server.
  """
  @spec parse_events(String.t()) ::
          {:ok, [Excalt.Event.t()] | nil} | {:error, any()}
  def parse_events(xml_doc) do
    Saxy.parse_string(xml_doc, Excalt.XML.EventHandler, {nil, []})
  end

  @doc """
  Same as parse_events/1, but raises errors
  """
  @spec parse_events!(String.t()) ::
          [Excalt.Event.t()] | no_return
  def parse_events!(xml_doc) do
    {:ok, events} = Saxy.parse_string(xml_doc, Excalt.XML.EventHandler, {nil, []})
    events
  end

  @doc """
  Parse the list of todos returned by the caldav server.
  """
  def parse_todos(xml_doc) do
    Saxy.parse_string(xml_doc, Excalt.XML.TodoHandler, {nil, []})
  end

  @doc """
  Same as parse_todos/1, but raises errors
  """
  def parse_todos!(xml_doc) do
    {:ok, todos} = Saxy.parse_string(xml_doc, Excalt.XML.TodoHandler, {nil, []})
    todos
  end

  @doc """
  Parse the list of principals returned by the caldav server.
  """
  def parse_principals(xml_doc) do
    Saxy.parse_string(xml_doc, Excalt.XML.PrincipalHandler, {nil, []})
  end

  @doc """
  Same as parse_principals/1, but raises errors
  """
  def parse_principals!(xml_doc) do
    {:ok, principals} = Saxy.parse_string(xml_doc, Excalt.XML.PrincipalHandler, {nil, nil, []})
    principals
  end

  @doc """
  Parse the list of principals returned by the caldav server.
  """
  def parse_calendars(xml_doc) do
    Saxy.parse_string(xml_doc, Excalt.XML.CalendarHandler, {nil, []})
  end

  @doc """
  Same as parse_calendars/1, but raises errors
  """
  def parse_calendars!(xml_doc) do
    {:ok, calendars} = Saxy.parse_string(xml_doc, Excalt.XML.CalendarHandler, {nil, []})
    calendars
  end
end
