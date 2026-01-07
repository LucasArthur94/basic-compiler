defmodule BasicCompiler.Lexer.ReservedKeywords do
  @moduledoc """
  Recognizes and marks reserved keywords.
  """

  alias BasicCompiler.Helpers.{Token, LexerAutomatas}

  @doc """
  Identifies reserved keywords in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with reserved keywords identified
  """
  def build_tokens(tokens) do
    reserved_words = LexerAutomatas.reserved_words()
    do_build_tokens(tokens, [], [], reserved_words)
  end

  defp do_build_tokens([], result_tokens, reserved_stack, _reserved_words) do
    # Flush remaining stack
    result_tokens
    |> push_stack(reserved_stack)
    |> Enum.reverse()
  end

  defp do_build_tokens([token | rest], result_tokens, reserved_stack, reserved_words) do
    case token.type do
      :letter ->
        new_stack = [token | reserved_stack]
        new_string = build_string_by_tokens(Enum.reverse(new_stack))

        if new_string in reserved_words do
          # Found a complete reserved word
          reserved_token = Token.new(new_string, :reserved, Enum.reverse(new_stack))
          do_build_tokens(rest, [reserved_token | result_tokens], [], reserved_words)
        else
          # Continue building
          do_build_tokens(rest, result_tokens, new_stack, reserved_words)
        end

      _ ->
        # Not a letter, flush stack and add current token
        new_result = push_stack(result_tokens, reserved_stack)
        do_build_tokens(rest, [token | new_result], [], reserved_words)
    end
  end

  defp push_stack(result_tokens, []), do: result_tokens

  defp push_stack(result_tokens, reserved_stack) do
    Enum.reduce(Enum.reverse(reserved_stack), result_tokens, fn token, acc ->
      [token | acc]
    end)
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
