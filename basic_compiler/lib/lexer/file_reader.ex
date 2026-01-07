defmodule BasicCompiler.Lexer.FileReader do
  @moduledoc """
  Reads a BASIC source file from disk.
  """

  @doc """
  Reads the contents of a file.

  ## Parameters
    - filename: Path to the file to read

  ## Returns
    - String content of the file
  """
  def read_file(filename) do
    case File.read(filename) do
      {:ok, content} -> content
      {:error, reason} -> raise "Failed to read file: #{reason}"
    end
  end
end
