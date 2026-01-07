defmodule BasicCompiler do
  @moduledoc """
  Main entry point for the BASIC compiler.
  Orchestrates the complete compilation pipeline from file reading to token generation.
  """

  alias BasicCompiler.Lexer.{FileReader, LineParser, CharParser, AsciiCategorizer}
  alias BasicCompiler.{Lexer, Parser}

  @doc """
  Compiles a BASIC source file through the complete pipeline.

  ## Parameters
    - filename: Path to the BASIC source file

  ## Returns
    - List of Token structs representing the parsed program
  """
  def compile(filename) do
    # Nível 0 de abstração - File reading
    content = FileReader.read_file(filename)

    # Nível 1 de abstração - Line parsing
    lines = LineParser.parse_lines(content)

    # Nível 2 de abstração - Character parsing
    chars_per_line = CharParser.parse_char_all_lines(lines)

    # Níveis 3 e 4 de abstração - Character classification
    chars_classified_per_line = AsciiCategorizer.classify_char_all_lines(chars_per_line)

    # Nível 5 e 6 de abstração - Lexical analysis
    tokens_per_line = Lexer.execute_lexer(chars_classified_per_line)

    # Nível 7 de abstração - Parsing
    tokens_per_line = Parser.execute_parser(tokens_per_line)

    tokens_per_line
  end

  @doc """
  Compiles and prints tokens from a BASIC source file.

  ## Parameters
    - filename: Path to the BASIC source file
  """
  def compile_and_print(filename) do
    tokens = compile(filename)

    Enum.each(tokens, fn token ->
      IO.puts("=============")
      IO.inspect(token)
    end)
  end

  @doc """
  Main entry point when running from command line.

  ## Parameters
    - args: Command line arguments (expects filename as first argument)
  """
  def main(args) do
    case args do
      [filename | _] ->
        compile_and_print(filename)

      [] ->
        IO.puts("Usage: basic_compiler <filename>")
        System.halt(1)
    end
  end
end
