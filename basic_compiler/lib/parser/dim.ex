defmodule BasicCompiler.Parser.Dim do
  @moduledoc """
  Recognizes DIM statements (DIM followed by one or more array declarations).
  """

  alias BasicCompiler.Helpers.{Token, ParserError}

  @doc """
  Identifies DIM tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with DIM statements recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, _token_stack, _state) do
    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:reserved, "DIM", :idle} ->
        # Start DIM
        do_build_tokens(rest, result_tokens, [token], :dim)

      {:reserved, "DIM", :dim_component} ->
        # Finish previous DIM and start new one
        dim_string = build_string_by_tokens(Enum.reverse(token_stack))
        dim_token = Token.new(dim_string, :dim, Enum.reverse(token_stack))
        do_build_tokens(rest, [dim_token | result_tokens], [token], :dim)

      {:reserved, _, :idle} ->
        # Other reserved word
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:reserved, _, :dim_component} ->
        # Finish DIM
        dim_string = build_string_by_tokens(Enum.reverse(token_stack))
        dim_token = Token.new(dim_string, :dim, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, dim_token | result_tokens], [], :idle)

      {:reserved, _, _} ->
        # Error
        raise ParserError, message: "erro na construção de DIM"

      {:dim_component, _, :idle} ->
        # Expand child tokens
        new_result = expand_child_tokens(result_tokens, token)
        do_build_tokens(rest, new_result, [], :idle)

      {:dim_component, _, :dim_component} ->
        # Finish DIM and expand child tokens
        dim_string = build_string_by_tokens(Enum.reverse(token_stack))
        dim_token = Token.new(dim_string, :dim, Enum.reverse(token_stack))
        new_result = expand_child_tokens([dim_token | result_tokens], token)
        do_build_tokens(rest, new_result, [], :idle)

      {:dim_component, _, state} when state in [:comma, :dim] ->
        # Add component to DIM
        do_build_tokens(rest, result_tokens, [token | token_stack], :dim_component)

      {:special, ",", :idle} ->
        # Regular comma
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, ",", :dim_component} ->
        # Comma in DIM list
        do_build_tokens(rest, result_tokens, [token | token_stack], :comma)

      {:special, ",", _} ->
        # Error
        raise ParserError, message: "erro na construção de DIM"

      {:special, _, :idle} ->
        # Other special character
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, _, :dim_component} ->
        # Finish DIM
        dim_string = build_string_by_tokens(Enum.reverse(token_stack))
        dim_token = Token.new(dim_string, :dim, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, dim_token | result_tokens], [], :idle)

      {:special, _, _} ->
        # Error
        raise ParserError, message: "erro na construção de DIM"

      {_, _, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_, _, :dim_component} ->
        # Finish DIM
        dim_string = build_string_by_tokens(Enum.reverse(token_stack))
        dim_token = Token.new(dim_string, :dim, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, dim_token | result_tokens], [], :idle)

      {_, _, _} ->
        # Error
        raise ParserError, message: "erro na construção de DIM"
    end
  end

  defp expand_child_tokens(result_tokens, token) do
    Enum.reduce(Enum.reverse(token.child_tokens), result_tokens, fn child, acc ->
      [child | acc]
    end)
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
