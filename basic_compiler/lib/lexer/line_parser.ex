defmodule BasicCompiler.Lexer.LineParser do
  @moduledoc """
  Parses file content into lines.
  """

  @doc """
  Splits content into lines, preserving newlines.

  ## Parameters
    - content: String content to split into lines

  ## Returns
    - List of lines with newlines preserved
  """
  def parse_lines(content) do
    content
    |> String.split(~r/(?<=\n)/)
    |> Enum.reject(&(&1 == ""))
  end
end
