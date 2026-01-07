defmodule BasicCompiler.Lexer.NumberRecognizer do
  @moduledoc """
  Recognizes floating point and scientific notation numbers.
  Handles patterns like: 123.456, .789, 1.2E10, 1.2E+10, 1.2E-10
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Identifies number tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with numbers recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, _token_stack, _state) do
    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:integer, _, :idle} ->
        # Start with integer
        do_build_tokens(rest, result_tokens, [token], :recognized_int)

      {:special, ".", :idle} ->
        # Start with dot (e.g., .5)
        do_build_tokens(rest, result_tokens, [token], :recognized_dot)

      {:integer, _, :recognized_int} ->
        # Continue after dot
        do_build_tokens(rest, result_tokens, [token | token_stack], :partial_recognition)

      {:integer, _, :recognized_dot} ->
        # Integer after dot
        do_build_tokens(rest, result_tokens, [token | token_stack], :partial_recognition)

      {:integer, _, :recognized_E} ->
        # Integer after E
        number_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
        number_token = Token.new(number_string, :number, Enum.reverse([token | token_stack]))
        do_build_tokens(rest, [number_token | result_tokens], [], :idle)

      {:integer, _, :recognized_signal} ->
        # Integer after E+/-
        number_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
        number_token = Token.new(number_string, :number, Enum.reverse([token | token_stack]))
        do_build_tokens(rest, [number_token | result_tokens], [], :idle)

      {:integer, _, :partial_recognition} ->
        # Check if first token was integer (not dot)
        first_type = List.last(token_stack).type

        if first_type == :integer do
          # Continue building
          do_build_tokens(rest, result_tokens, [token | token_stack], :partial_recognition)
        else
          # Finish number and add current token
          number_string = build_string_by_tokens(Enum.reverse(token_stack))
          number_token = Token.new(number_string, :number, Enum.reverse(token_stack))
          do_build_tokens(rest, [token, number_token | result_tokens], [], :idle)
        end

      {:special, ".", :recognized_int} ->
        # Dot after integer
        do_build_tokens(rest, result_tokens, [token | token_stack], :partial_recognition)

      {:special, sign, :recognized_E} when sign in ["+", "-"] ->
        # Sign after E
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognized_signal)

      {:special, sign, :partial_recognition} when sign in ["+", "-"] ->
        # Finish number and add sign
        number_string = build_string_by_tokens(Enum.reverse(token_stack))
        number_token = Token.new(number_string, :number, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, number_token | result_tokens], [], :idle)

      {:special, _, state} when state in [:recognized_int, :recognized_dot, :partial_recognition] ->
        # Cancel and flush
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {:letter, "E", :partial_recognition} ->
        # Scientific notation
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognized_E)

      {:letter, _, :partial_recognition} ->
        # Finish number and add letter
        number_string = build_string_by_tokens(Enum.reverse(token_stack))
        number_token = Token.new(number_string, :number, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, number_token | result_tokens], [], :idle)

      {:letter, _, state} when state in [:recognized_int, :recognized_dot] ->
        # Cancel
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {_, _, :partial_recognition} ->
        # Finish number
        number_string = build_string_by_tokens(Enum.reverse(token_stack))
        number_token = Token.new(number_string, :number, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, number_token | result_tokens], [], :idle)

      {_, _, state} when state in [:recognized_int, :recognized_dot, :recognized_E] ->
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
