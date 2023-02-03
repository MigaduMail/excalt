defmodule Excalt.Helpers.Request do
  @doc """
  Extract a specific field from the header of the request.
  """
  defp extract_from_header(header, field) do
    [{_, value}] =
      Enum.filter(header, fn
        {key, value} ->
          if key == field, do: true, else: false
      end)

    value
  end
end
