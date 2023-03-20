defmodule Excalt.Helpers.Request do
  @doc """
  Extract a specific field from the header of the request.
  """
  def extract_from_header(header, field) do
    result =
      Enum.filter(header, fn
        {key, value} ->
          if key == field, do: true, else: false
      end)

    case result do
      [] ->
        ""
      [{_, value}] ->
        value
    end
   end
end
