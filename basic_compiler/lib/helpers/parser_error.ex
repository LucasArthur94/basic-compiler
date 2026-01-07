defmodule BasicCompiler.Helpers.ParserError do
  @moduledoc """
  Exception raised when parser encounters an error.
  """

  defexception message: "Parser error occurred"
end
