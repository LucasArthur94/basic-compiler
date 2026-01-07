defmodule BasicCompiler.Lexer.Integer do
  @moduledoc """
  Recognizes integer tokens (sequences of digits).
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Identifies integer tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with integers recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, token_stack, state) do
    # Flush remaining integer if any
    result_tokens =
      if state == :recognizing do
        integer_string = build_string_by_tokens(Enum.reverse(token_stack))
        integer_token = Token.new(integer_string, :integer, Enum.reverse(token_stack))
        [integer_token | result_tokens]
      else
        result_tokens
      end

    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, state} do
      {:digit, _} ->
        # Recognize digit
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognizing)

      {_type, :recognizing} ->
        # Finish integer and add current token
        integer_string = build_string_by_tokens(Enum.reverse(token_stack))
        integer_token = Token.new(integer_string, :integer, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, integer_token | result_tokens], [], :idle)

      {_type, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)
    end
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
