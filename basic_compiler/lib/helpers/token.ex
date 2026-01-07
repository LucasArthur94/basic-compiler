defmodule BasicCompiler.Helpers.Token do
  @moduledoc """
  Represents a token in the BASIC compiler with a string value, type, and child tokens.
  """

  defstruct [:string, :type, :child_tokens]

  @type t :: %__MODULE__{
          string: String.t(),
          type: atom(),
          child_tokens: list()
        }

  @doc """
  Creates a new Token.
  """
  def new(string, type, child_tokens \\ []) do
    %__MODULE__{
      string: string,
      type: type,
      child_tokens: child_tokens
    }
  end
end
