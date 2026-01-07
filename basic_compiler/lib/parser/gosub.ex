defmodule BasicCompiler.Parser.Gosub do
  @moduledoc """
  Recognizes GOSUB statements (GOSUB followed by an integer).
  """

  alias BasicCompiler.Helpers.{Token, ParserError}

  @doc """
  Identifies GOSUB tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with GOSUB statements recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, _token_stack, _state) do
    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:reserved, "GOSUB", :idle} ->
        # Recognize GOSUB
        do_build_tokens(rest, result_tokens, [token], :gosub)

      {:reserved, _, :idle} ->
        # Other reserved word
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:reserved, _, :gosub} ->
        # Error: reserved word after GOSUB
        raise ParserError, message: "erro na construção de GOSUB"

      {:integer, _, :idle} ->
        # Regular integer
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:integer, _, :gosub} ->
        # Complete GOSUB statement
        gosub_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
        gosub_token = Token.new(gosub_string, :integer, Enum.reverse([token | token_stack]))
        do_build_tokens(rest, [gosub_token | result_tokens], [], :idle)

      {_, _, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_, _, :gosub} ->
        # Error: unexpected token after GOSUB
        raise ParserError, message: "erro na construção de GOSUB"
    end
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
