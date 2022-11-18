defmodule Excalt.Calendar do
  @moduledoc """
  Execute the requests to CRUD the calender objects of the CalDav server.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          url: String.t(),
          type: String.t(),
          timezone: String.t()
        }
  defstruct name: nil,
            url: nil,
            type: nil,
            timezone: nil

  @doc """
  Fetches the raw xml of the calendars for a user from the CalDav server.
  """
  @spec list_raw(server_url :: String.t(), username :: String.t(), password :: String.t()) ::
          {:ok, xml :: String.t()} | {:error, any()}
  def list_raw(server_url, username, password) do
    auth_header_content = "Basic " <> Base.encode64("#{username}:#{password}")

    req_body = Excalt.XML.Builder.calendar_list()
    req_url = Excalt.Request.UrlHelper.build_url(server_url, username)

    finch_req =
      Finch.build(
        "PROPFIND",
        req_url,
        [
          {"Authorization", auth_header_content}
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
  @spec list!(server_url :: String.t(), username :: String.t(), password :: String.t()) ::
          {:ok, xml :: String.t()} | {:error, any()}
  def list!(server_url, username, password) do
    {:ok, xml_text} = list_raw(server_url, username, password)
    Excalt.XML.Parser.parse_calendars!(xml_text)
  end
end
