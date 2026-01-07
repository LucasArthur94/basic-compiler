defmodule BasicCompiler.Parser.Data do
  @moduledoc """
  Recognizes DATA statements (DATA followed by comma-separated numbers).
  """

  alias BasicCompiler.Helpers.{Token, ParserError}

  @doc """
  Identifies DATA tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with DATA statements recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, token_stack, state) do
    # Flush any remaining DATA token
    result_tokens =
      if state == :snum and length(token_stack) > 0 do
        data_string = build_string_by_tokens(Enum.reverse(token_stack))
        data_token = Token.new(data_string, :data, Enum.reverse(token_stack))
        [data_token | result_tokens]
      else
        result_tokens
      end

    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:reserved, "DATA", :idle} ->
        # Start DATA
        do_build_tokens(rest, result_tokens, [token], :data)

      {:reserved, "DATA", :snum} ->
        # Finish previous DATA and start new one
        data_string = build_string_by_tokens(Enum.reverse(token_stack))
        data_token = Token.new(data_string, :data, Enum.reverse(token_stack))
        do_build_tokens(rest, [data_token | result_tokens], [token], :data)

      {:reserved, _, :idle} ->
        # Other reserved word
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:reserved, _, :snum} ->
        # Finish DATA
        data_string = build_string_by_tokens(Enum.reverse(token_stack))
        data_token = Token.new(data_string, :data, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, data_token | result_tokens], [], :idle)

      {:reserved, _, _} ->
        # Error
        raise ParserError, message: "erro na construção de DATA"

      {type, _, :idle} when type in [:integer, :number, :signed_number] ->
        # Regular number
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {type, _, state} when type in [:integer, :number, :signed_number] and state in [:data, :comma] ->
        # Number in DATA list
        do_build_tokens(rest, result_tokens, [token | token_stack], :snum)

      {type, _, :snum} when type in [:integer, :number, :signed_number] ->
        # Finish DATA and add number
        data_string = build_string_by_tokens(Enum.reverse(token_stack))
        data_token = Token.new(data_string, :data, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, data_token | result_tokens], [], :idle)

      {type, _, _} when type in [:integer, :number, :signed_number] ->
        # Error
        raise ParserError, message: "erro na construção de DATA"

      {:special, ",", :idle} ->
        # Regular comma
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, ",", :snum} ->
        # Comma in DATA list
        do_build_tokens(rest, result_tokens, [token | token_stack], :comma)

      {:special, ",", _} ->
        # Error
        raise ParserError, message: "erro na construção de DATA"

      {:special, _, :idle} ->
        # Other special character
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, _, :snum} ->
        # Finish DATA
        data_string = build_string_by_tokens(Enum.reverse(token_stack))
        data_token = Token.new(data_string, :data, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, data_token | result_tokens], [], :idle)

      {:special, _, _} ->
        # Error
        raise ParserError, message: "erro na construção de DATA"

      {_, _, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_, _, :snum} ->
        # Finish DATA
        data_string = build_string_by_tokens(Enum.reverse(token_stack))
        data_token = Token.new(data_string, :data, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, data_token | result_tokens], [], :idle)

      {_, _, _} ->
        # Error
        raise ParserError, message: "erro na construção de DATA"
    end
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
