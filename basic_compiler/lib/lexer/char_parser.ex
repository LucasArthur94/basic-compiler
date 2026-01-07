defmodule BasicCompiler.Lexer.CharParser do
  @moduledoc """
  Parses lines into individual characters.
  """

  @doc """
  Splits all lines into individual characters.

  ## Parameters
    - lines: List of lines to parse

  ## Returns
    - List of lists, where each inner list contains the characters of a line
  """
  def parse_char_all_lines(lines) do
    Enum.map(lines, &parse_char/1)
  end

  defp parse_char(line) do
    String.graphemes(line)
  end
end
