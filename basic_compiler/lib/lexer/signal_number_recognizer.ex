defmodule BasicCompiler.Lexer.SignalNumberRecognizer do
  @moduledoc """
  Recognizes signed numbers (numbers with + or - prefix).
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Identifies signed number tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with signed numbers recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, _token_stack, _state) do
    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:special, sign, :idle} when sign in ["+", "-"] ->
        # Recognize sign
        do_build_tokens(rest, result_tokens, [token], :recognized_signal)

      {:special, sign, :recognized_signal} when sign in ["+", "-"] ->
        # Another sign, flush previous and start new
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, new_result, [token], :recognized_signal)

      {:special, _, :recognized_signal} ->
        # Other special character, cancel
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {type, _, :recognized_signal} when type in [:number, :integer] ->
        # Complete signed number
        signed_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
        signed_token = Token.new(signed_string, :signed_number, Enum.reverse([token | token_stack]))
        do_build_tokens(rest, [signed_token | result_tokens], [], :idle)

      {_, _, :recognized_signal} ->
        # Cancel
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {_, _, :idle} ->
        # Regular token
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
