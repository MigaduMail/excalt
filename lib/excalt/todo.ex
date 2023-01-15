defmodule Excalt.Todo do
  @type t :: %__MODULE__{
          icalendar: String.t(),
          url: String.t(),
          etag: String.t()
        }
  defstruct icalendar: nil,
            url: nil,
            etag: nil
end
