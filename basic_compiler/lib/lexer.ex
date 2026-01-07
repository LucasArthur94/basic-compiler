defmodule BasicCompiler.Lexer do
  @moduledoc """
  Main lexer orchestrator that runs all lexer stages in sequence.
  """

  alias BasicCompiler.Lexer.{
    StringBuilder,
    RemBuilder,
    ClearDelimiter,
    ReservedKeywords,
    Identifier,
    Integer,
    NumberRecognizer,
    SignalNumberRecognizer
  }

  @doc """
  Executes the complete lexer pipeline.

  ## Parameters
    - chars_classified_per_line: List of lists of ClassifiedChar structs

  ## Returns
    - List of Token structs
  """
  def execute_lexer(chars_classified_per_line) do
    chars_classified_per_line
    |> StringBuilder.build_tokens()
    |> RemBuilder.build_tokens()
    |> ClearDelimiter.build_tokens()
    |> ReservedKeywords.build_tokens()
    |> Identifier.build_tokens()
    |> Integer.build_tokens()
    |> NumberRecognizer.build_tokens()
    |> SignalNumberRecognizer.build_tokens()
  end
end
