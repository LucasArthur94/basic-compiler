defmodule BasicCompiler.Parser.DimComponent do
  @moduledoc """
  Recognizes DIM components (array declarations like A(5) or B(2,3)).
  """

  alias BasicCompiler.Helpers.Token

  @doc """
  Identifies DIM component tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with DIM components recognized
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
    case {token.type, token.string, state} do
      {:letter, _, :idle} ->
        # Start recognizing
        do_build_tokens(rest, result_tokens, [token], :letter)

      {:letter, _, _} ->
        # Reset and start new
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, new_result, [token], :letter)

      {:special, "(", :idle} ->
        # Regular parenthesis
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, "(", :letter} ->
        # Open parenthesis after letter
        do_build_tokens(rest, result_tokens, [token | token_stack], :open_parenthesis)

      {:special, "(", _} ->
        # Reset
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {:special, ")", :idle} ->
        # Regular parenthesis
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, ")", :digit} ->
        # Close parenthesis - complete DIM component
        dim_string = build_string_by_tokens(Enum.reverse([token | token_stack]))
        dim_token = Token.new(dim_string, :dim_component, Enum.reverse([token | token_stack]))
        do_build_tokens(rest, [dim_token | result_tokens], [], :idle)

      {:special, ")", _} ->
        # Reset
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {:special, ",", :idle} ->
        # Regular comma
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:special, ",", :digit} ->
        # Comma in dimension list
        do_build_tokens(rest, result_tokens, [token | token_stack], :comma)

      {:special, ",", _} ->
        # Reset
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {:special, _, _} ->
        # Other special character - reset
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {:integer, _, :idle} ->
        # Regular integer
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {:integer, _, state} when state in [:open_parenthesis, :comma] ->
        # Integer in dimension list (must be single digit)
        if String.length(token.string) == 1 do
          do_build_tokens(rest, result_tokens, [token | token_stack], :digit)
        else
          # Reset
          new_result = push_stack(result_tokens, token_stack)
          do_build_tokens(rest, [token | new_result], [], :idle)
        end

      {:integer, _, _} ->
        # Reset
        new_result = push_stack(result_tokens, token_stack)
        do_build_tokens(rest, [token | new_result], [], :idle)

      {_, _, :idle} ->
        # Other token
        do_build_tokens(rest, [token | result_tokens], [], :idle)

      {_, _, _} ->
        # Reset
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
