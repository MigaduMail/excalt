defmodule Excalt.Principal do
  @moduledoc """
  Allows fetching and modifications of the principal.
  """
  @type t :: %__MODULE__{
          current_user_principal: String.t(),
          url: String.t(),
          resource_type: String.t()
        }
  defstruct current_user_principal: nil,
            url: nil,
            resource_type: nil
end
