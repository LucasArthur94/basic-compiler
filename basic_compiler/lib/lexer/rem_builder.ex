defmodule BasicCompiler.Lexer.RemBuilder do
  @moduledoc """
  Recognizes and builds REM (remark/comment) tokens.
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Builds tokens from existing tokens, recognizing REM statements.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with REM statements combined
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, token_stack, _state) do
    # Flush any remaining tokens
    result_tokens
    |> push_stack(token_stack)
    |> Enum.reverse()
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.string, state} do
      {"R", :idle} ->
        do_build_tokens(rest, result_tokens, [token], :recognizing)

      {"E", :recognizing} ->
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognizing)

      {"M", :recognizing} ->
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognized)

      {"\n", :recognized} ->
        # Build REM token
        merged_string = build_string_by_tokens(Enum.reverse(token_stack))
        rem_token = Token.new(merged_string, :rem, [])
        do_build_tokens(rest, [token, rem_token | result_tokens], [], :idle)

      {_char, :recognized} ->
        # Continue building REM content
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognized)

      {_char, :recognizing} ->
        # Cancel recognizing, flush stack
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {_char, :idle} ->
        do_build_tokens(rest, [token | result_tokens], [], :idle)
    end
  end

  defp push_stack(result_tokens, []), do: result_tokens

  defp push_stack(result_tokens, token_stack) do
    Enum.reduce(Enum.reverse(token_stack), result_tokens, fn token, acc ->
      [token | acc]
    end)
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
