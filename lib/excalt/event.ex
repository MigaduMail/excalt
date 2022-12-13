defmodule Excalt.Event do
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
          calendar_name :: String.t(),
          from :: DateTime.t(),
          to :: DateTime.t()
        ) ::
          {:ok, xml :: String.t()} | {:error, any()}
  def list_raw(server_url, username, password, calendar_name, from, to) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = Excalt.XML.Builder.event_list(from, to)
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username, calendar_name)

    IO.inspect req_body: req_body


    finch_req =
      Finch.build(
        "PROPFIND",
        req_url,
        [
          {"Authorization", auth_header_content},
          {"Depth", "1"}
        ],
        req_body
      )

    IO.inspect(finch_req: finch_req)

    case Finch.request(finch_req, ExcaltFinch)
         |> IO.inspect() do
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
    end
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
end
