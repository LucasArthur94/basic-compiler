defmodule BasicCompiler.Lexer.Identifier do
  @moduledoc """
  Recognizes identifier tokens (letter followed by optional digit).
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Identifies identifier tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with identifiers recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, token_stack, _state) do
    # Flush remaining stack
    result_tokens
    |> push_stack(token_stack)
    |> Enum.reverse()
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, state} do
      {:letter, :idle} ->
        # Start recognizing identifier
        do_build_tokens(rest, result_tokens, [token], :recognized)

      {:letter, :recognized} ->
        # Another letter, finish current identifier and start new one
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, new_result, [token], :recognized)

      {:integer, :idle} ->
        # Integer not in identifier
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:integer, :recognized} ->
        # Complete identifier with digit
        new_stack = [token | token_stack]
        identifier_string = build_string_by_tokens(Enum.reverse(new_stack))
        identifier_token = Token.new(identifier_string, :identifier, Enum.reverse(new_stack))
        do_build_tokens(rest, [identifier_token | result_tokens], [], :idle)

      {_type, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_type, :recognized} ->
        # Finish identifier and add current token
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)
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
