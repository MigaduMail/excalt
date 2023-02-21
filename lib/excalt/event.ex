defmodule Excalt.Event do
  @moduledoc """
  Fetches events from the caldav server, modifies events, and deletes events.
  """
  @type t :: %__MODULE__{
          icalendar: String.t(),
          url: String.t(),
          etag: String.t()
        }
  defstruct icalendar: nil,
            url: nil,
            etag: nil

  @doc """
  Fetches the raw xml of the events for a user from the CalDav server.
  """
  @spec list_raw(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t()
        ) ::
          {:ok, xml :: String.t()} | {:error, any()}
  def list_raw(server_url, username, password, calendar_name) do
    list_raw(server_url, username, password, calendar_name, nil, nil)
  end

  @doc """
  Fetches the raw xml of the events for a user and a time duration from the CalDav server.
  """
  @spec list_raw(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          from :: DateTime.t(),
          to :: DateTime.t()
        ) ::
          {:ok, xml :: String.t()} | {:error, any()}
  def list_raw(server_url, username, password, calendar_name, from, to) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = Excalt.XML.Builder.event_list(from, to)
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username, calendar_name)


    finch_req =
      Finch.build(
        "REPORT",
        req_url,
        [
          {"Authorization", auth_header_content},
          {"Depth", "1"}
        ],
        req_body
      )

    case Finch.request(finch_req, ExcaltFinch) do
      {:ok,
       %Finch.Response{
         status: 207,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 401,
         body: body
       }} ->
        {:error, body}

      {:ok,
       %Finch.Response{
         status: 412,
         body: body
       }} ->
        {:error, body}

      {:ok,
       %Finch.Response{
         status: 404,
         body: body
       }} ->
        {:error, :not_found}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns the parsed xml of the calendars for a user from the CalDav server.
  """
  @spec list!(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t()
        ) :: [t()]
  def list!(server_url, username, password, calendar_name) do
    {:ok, xml_text} = list_raw(server_url, username, password, calendar_name)
    Excalt.XML.Parser.parse_events!(xml_text)
  end

  @doc """
  Returns the parsed xml of the calendars for a user from the CalDav server.
  """
  @spec list!(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          from :: DateTime.t(),
          to :: DateTime.t()
        ) :: [t()]
  def list!(server_url, username, password, calendar_name, from, to) do
    {:ok, xml_text} = list_raw(server_url, username, password, calendar_name, from, to)
    Excalt.XML.Parser.parse_events!(xml_text)
  end

  @doc """
  Returns the parsed list of events for a period of time, where also the icalendar parts are parsed.
  """
  @spec parsed_list!(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          from :: DateTime.t(),
          to :: DateTime.t()
        ) :: [t()]
  def parsed_list!(server_url, username, password, calendar_name, from, to) do
    list!(server_url, username, password, calendar_name, from, to)
    |> Enum.map(fn e ->
      %Excalt.Event{url: url, etag: etag, icalendar: icalendar} = e

      # %Excalt.Event{url: url, etag: etag, icalendar: Exicalend.Parser.from_ical(icalendar)}
    end)
  end

  @doc """
  Creates a new event item with the given icalendar text.
  """
  @spec create(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          ical_text :: String.t(),
          uuid :: String.t()
        ) ::
          {:ok, etag :: String.t() | nil} | {:error, any()}

  def create(server_url, username, password, calendar_name, ical_text, uuid) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = ical_text
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username, calendar_name)

    finch_req =
      Finch.build(
        "PUT",
        req_url <> "/#{uuid}.ical",
        [
          {"Authorization", auth_header_content},
          # {"if-match", etag}
          {"If-None-Match", "*"}
        ],
        req_body
      )

    case Finch.request(finch_req, ExcaltFinch) do
      {:ok,
       %Finch.Response{
         status: 201,
         body: body,
         headers: headers
       }} ->
        etag = Excalt.Helpers.Request.extract_from_header(headers, "etag")
        {:ok, etag}

      {:ok,
       %Finch.Response{
         status: 204,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 404,
         body: body
       }} ->
        {:error, :not_found, body}

      {:ok,
       %Finch.Response{
         status: 412,
         body: body
       }} ->
        {:error, :bad_etag, body}

      {:ok,
       %Finch.Response{
         status: status,
         body: body
       }} ->
        {:error, status, body}
    end
  end

  @doc """
  Deletes an event with the given uuid.
  """
  @spec delete(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          uuid :: String.t()
        ) ::
          {:ok, etag :: String.t() | nil} | {:error, any()}

  def delete(server_url, username, password, calendar_name, uuid) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = ""
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username, calendar_name)

    finch_req =
      Finch.build(
        "DELETE",
        req_url <> "/#{uuid}.ical",
        [
          {"Authorization", auth_header_content}
        ],
        req_body
      )

    case Finch.request(finch_req, ExcaltFinch) do
      {:ok,
       %Finch.Response{
         status: 201,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 204,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 404,
         body: body
       }} ->
        {:error, :not_found}
    end
  end

  @doc """
  Updates a single event, given an uid of the event, the new version, and the etag.
  Will throw an error, if the etag has changed in the meantime.
  (see [RFC 4791, section 7.8.1](https://tools.ietf.org/html/rfc4791#section-7.8.9)).
  """
  @spec update(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          uuid :: String.t(),
          ical_text :: String.t(),
          etag :: String.t(),
          opts :: keyword()
        ) :: {:ok, [t()]} | {:error, any()}
  def update(server_url, username, password, calendar_name, uuid, ical_text, etag, opts \\ []) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = ""
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username, calendar_name)

    finch_req =
      Finch.build(
        "PUT",
        req_url <> "/#{uuid}.ical",
        [
          {"Authorization", auth_header_content}
        ],
        req_body
      )


    case Finch.request(finch_req, ExcaltFinch) do
      {:ok,
       %Finch.Response{
         status: 201,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 204,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 404,
         body: body
       }} ->
        {:error, :not_found}
    end
  end

  @doc """
  Updates a single event, given an uid of the event, the new version, and the etag.
  Will throw an error, if the etag has changed in the meantime.
  (see [RFC 4791, section 7.8.1](https://tools.ietf.org/html/rfc4791#section-7.8.9)).
  """
  @spec get(
          server_url :: String.t(),
          username :: String.t(),
          password :: String.t(),
          calendar_name :: String.t(),
          uuid :: String.t(),
          opts :: keyword()
        ) :: {:ok, [t()]} | {:error, any()}
  def get(server_url, username, password, calendar_name, uuid, opts \\ []) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = ""
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username, calendar_name)

    finch_req =
      Finch.build(
        "GET",
        req_url <> "/#{uuid}.ical",
        [
          {"Authorization", auth_header_content}
        ],
        req_body
      )


    case Finch.request(finch_req, ExcaltFinch) do
      {:ok,
       %Finch.Response{
         status: 201,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 204,
         body: body
       }} ->
        {:ok, body}

      {:ok,
       %Finch.Response{
         status: 404,
         body: body
       }} ->
        {:error, :not_found}
    end
  end
end
