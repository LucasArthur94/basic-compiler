defmodule BasicCompiler.Lexer.StringBuilder do
  @moduledoc """
  Recognizes and builds string tokens from classified characters.
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Builds tokens from classified characters, recognizing string literals.

  ## Parameters
    - chars_classified_per_line: List of lists of ClassifiedChar

  ## Returns
    - List of Token structs
  """
  def build_tokens(chars_classified_per_line) do
    chars_classified_per_line
    |> List.flatten()
    |> do_build_tokens([], "", :idle)
  end

  defp do_build_tokens([], tokens, "", _state), do: Enum.reverse(tokens)

  defp do_build_tokens([], tokens, partial_string, :build_string) do
    # Unclosed string - add as is
    Enum.reverse([Token.new(partial_string, :string, []) | tokens])
  end

  defp do_build_tokens([classified_char | rest], tokens, partial_string, state) do
    case {classified_char.char, state} do
      {"\"", :idle} ->
        # Start building a string
        do_build_tokens(rest, tokens, "\"", :build_string)

      {"\"", :build_string} ->
        # Finish building a string
        final_string = partial_string <> "\""
        new_token = Token.new(final_string, :string, [])
        do_build_tokens(rest, [new_token | tokens], "", :idle)

      {char, :build_string} ->
        # Continue building a string
        do_build_tokens(rest, tokens, partial_string <> char, :build_string)

      {char, :idle} ->
        # Not in a string, create token for this character
        new_token = Token.new(char, classified_char.type, [])
        do_build_tokens(rest, [new_token | tokens], "", :idle)
    end
  end
end
