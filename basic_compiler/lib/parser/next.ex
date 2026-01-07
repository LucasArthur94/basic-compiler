defmodule BasicCompiler.Parser.Next do
  @moduledoc """
  Recognizes NEXT statements (NEXT followed by an optional variable).
  """

  alias BasicCompiler.Helpers.{Token, ParserError}

  @doc """
  Identifies NEXT tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with NEXT statements recognized
  """
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end

  defp do_build_tokens([], result_tokens, token_stack, state) do
    # Flush any remaining NEXT token
    result_tokens =
      case state do
        :letter ->
          next_string = build_string_by_tokens(Enum.reverse(token_stack))
          next_token = Token.new(next_string, :next, Enum.reverse(token_stack))
          [next_token | result_tokens]

        :next ->
          next_token = Token.new("NEXT", :next, Enum.reverse(token_stack))
          [next_token | result_tokens]

        _ ->
          result_tokens
      end

    Enum.reverse(result_tokens)
  end

  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, token.string, state} do
      {:reserved, "NEXT", :idle} ->
        # Recognize NEXT
        do_build_tokens(rest, result_tokens, [token], :next)

      {:reserved, "NEXT", :letter} ->
        # Finish previous NEXT and start new one
        next_string = build_string_by_tokens(Enum.reverse(token_stack))
        next_token = Token.new(next_string, :next, Enum.reverse(token_stack))
        do_build_tokens(rest, [next_token | result_tokens], [token], :next)

      {:reserved, _, :idle} ->
        # Other reserved word
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:reserved, _, :letter} ->
        # Finish NEXT
        next_string = build_string_by_tokens(Enum.reverse(token_stack))
        next_token = Token.new(next_string, :next, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, next_token | result_tokens], [], :idle)

      {:reserved, _, :next} ->
        # Error
        raise ParserError, message: "erro na construção de NEXT"

      {:letter, _, :idle} ->
        # Regular letter
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:letter, _, :next} ->
        # Letter after NEXT
        do_build_tokens(rest, result_tokens, [token | token_stack], :letter)

      {:letter, _, :letter} ->
        # Finish previous NEXT and add letter
        next_string = build_string_by_tokens(Enum.reverse(token_stack))
        next_token = Token.new(next_string, :next, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, next_token | result_tokens], [], :idle)

      {:integer, _, :idle} ->
        # Regular integer
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:integer, _, :letter} ->
        # Check if single digit (variable like A1)
        if String.length(token.string) == 1 do
          # Complete NEXT with variable
          next_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
          next_token = Token.new(next_string, :next, Enum.reverse([token | token_stack]))
          do_build_tokens(rest, [next_token | result_tokens], [], :idle)
        else
          # Error
          raise ParserError, message: "erro na construção de NEXT"
        end

      {:integer, _, :next} ->
        # Error
        raise ParserError, message: "erro na construção de NEXT"

      {_, _, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_, _, :letter} ->
        # Finish NEXT and add token
        next_string = build_string_by_tokens(Enum.reverse(token_stack))
        next_token = Token.new(next_string, :next, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, next_token | result_tokens], [], :idle)

      {_, _, :next} ->
        # NEXT without variable - just output NEXT token
        next_token = Token.new("NEXT", :next, Enum.reverse(token_stack))
        do_build_tokens(rest, [token, next_token | result_tokens], [], :idle)
    end
  end

  defp build_string_by_tokens(token_list) do
    token_list
    |> Enum.map(& &1.string)
    |> Enum.join("")
  end
end
