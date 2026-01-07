defmodule BasicCompiler.Lexer.ClearDelimiter do
  @moduledoc """
  Removes whitespace delimiters but preserves newlines.
  """

  @doc """
  Filters out whitespace delimiters, keeping newlines.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with whitespace removed
  """
  def build_tokens(tokens) do
    Enum.filter(tokens, fn token ->
      case token.type do
        :delimiter ->
          token.string == "\n"

        _ ->
          true
      end
    end)
  end
end
