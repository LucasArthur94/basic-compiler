defmodule BasicCompiler.Helpers.LexerAutomatas do
  @moduledoc """
  Regular expressions and patterns for lexical analysis.
  """

  @doc """
  Returns the regular expression for delimiters (space and newline).
  """
  def delimiter, do: ~r/[ \n]/

  @doc """
  Returns the regular expression for letters.
  """
  def letter, do: ~r/[a-zA-Z]/

  @doc """
  Returns the regular expression for digits.
  """
  def digit, do: ~r/[0-9]/

  @doc """
  Returns the regular expression for special characters.
  """
  def special, do: ~r/[!\@\#\%¨\&\*\(\)\_\+\-\=§\{\[ª\}\]º\?\/°`´\^\~\<\,\>\.\:\;\|\\\"]/

  @doc """
  Returns the list of reserved keywords.
  """
  def reserved_words do
    ~w[ABS ATN COS DATA DEF DIM END EXP FN FOR GOSUB GOTO IF INT LET LOG NEXT PRINT READ REM RETURN RND SIN SQR STEP TAN THEN TO]
  end
end
