defmodule BasicCompiler.Lexer.AsciiCategorizer do
  @moduledoc """
  Categorizes characters into types (delimiter, letter, digit, special).
  """

  alias BasicCompiler.Helpers.{ClassifiedChar, LexerAutomatas}

  @doc """
  Classifies all characters in all lines.

  ## Parameters
    - chars_per_line: List of lists of characters

  ## Returns
    - List of lists of ClassifiedChar structs
  """
  def classify_char_all_lines(chars_per_line) do
    Enum.map(chars_per_line, &classify_line/1)
  end

  defp classify_line(line) do
    Enum.map(line, &classify_char/1)
  end

  defp classify_char(char) do
    cond do
      char =~ LexerAutomatas.delimiter() ->
        ClassifiedChar.new(char, :delimiter, false)

      char =~ LexerAutomatas.letter() ->
        ClassifiedChar.new(char, :letter, true)

      char =~ LexerAutomatas.digit() ->
        ClassifiedChar.new(char, :digit, true)

      char =~ LexerAutomatas.special() ->
        ClassifiedChar.new(char, :special, true)

      true ->
        ClassifiedChar.new(char, :letter, true)
    end
  end
end
