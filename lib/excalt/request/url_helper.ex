defmodule Excalt.Request.UrlHelper do
  @moduledoc """
  Helper functions to create the urls used for the caldav requests.
  """

  @doc """
  Builds the url for accessing the calendar of a user.
  """
  @spec build_url(server_url :: String.t(), username :: String.t()) :: String.t()
  def build_url(server_url, username) do
    "#{server_url}/calendars/#{URI.encode(username)}"
  end

  @doc """
  Builds the url for accessing the calendar of a user.

  ## Examples
      iex> Excalt.Request.UrlHelper.build_url("http://mycaldavserver.org", "myuser", "mycalendar")
      "http://mycaldavserver.org/myuser/mycalendar"
  """
  @spec build_url(server_url :: String.t(), username :: String.t(), calendar_name :: String.t()) ::
          String.t()
  def build_url(server_url, username, calendar_name) do
    "#{build_url(server_url, username)}/#{URI.encode(calendar_name)}"
  end
end
