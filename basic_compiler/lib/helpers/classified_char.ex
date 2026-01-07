defmodule BasicCompiler.Helpers.ClassifiedChar do
  @moduledoc """
  Represents a classified character with its type and utility flag.
  """

  defstruct [:char, :type, :util]

  @type t :: %__MODULE__{
          char: String.t(),
          type: atom(),
          util: boolean()
        }

  @doc """
  Creates a new ClassifiedChar.
  """
  def new(char, type, util) do
    %__MODULE__{
      char: char,
      type: type,
      util: util
    }
  end
end
