defmodule BasicCompiler.Parser do
  @moduledoc """
  Main parser orchestrator that runs all parser stages in sequence.
  """

  alias BasicCompiler.Parser.{
    Gosub,
    Goto,
    Predef,
    Data,
    Next,
    DimComponent,
    Dim
  }

  @doc """
  Executes the complete parser pipeline.

  ## Parameters
    - tokens: List of Token structs from the lexer

  ## Returns
    - List of Token structs with higher-level constructs recognized
  """
  def execute_parser(tokens) do
    tokens
    |> Gosub.build_tokens()
    |> Goto.build_tokens()
    |> Predef.build_tokens()
    |> Data.build_tokens()
    |> Next.build_tokens()
    |> DimComponent.build_tokens()
    |> Dim.build_tokens()
  end
end
