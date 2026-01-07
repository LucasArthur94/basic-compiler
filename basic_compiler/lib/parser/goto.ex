defmodule BasicCompiler.Parser.Goto do
  @moduledoc """
  Recognizes GOTO statements (GOTO followed by an integer).
  """

  alias BasicCompiler.Helpers.{Token, ParserError}

  @doc """
  Identifies GOTO tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with GOTO statements recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, _token_stack, _state) do
    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:reserved, "GOTO", :idle} ->
        # Recognize GOTO
        do_build_tokens(rest, result_tokens, [token], :goto)

      {:reserved, _, :idle} ->
        # Other reserved word
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:reserved, _, :goto} ->
        # Error: reserved word after GOTO
        raise ParserError, message: "erro na construção de GOTO"

      {:integer, _, :idle} ->
        # Regular integer
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:integer, _, :goto} ->
        # Complete GOTO statement
        goto_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
        goto_token = Token.new(goto_string, :integer, Enum.reverse([token | token_stack]))
        do_build_tokens(rest, [goto_token | result_tokens], [], :idle)

      {_, _, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_, _, :goto} ->
        # Error: unexpected token after GOTO
        raise ParserError, message: "erro na construção de GOTO"
    end
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
