defmodule BasicCompiler.Parser.Predef do
  @moduledoc """
  Recognizes predefined function names.
  """

  @predef_functions ~w[SIN COS TAN ATN EXP ABS LOG SQR INT RND]

  @doc """
  Identifies predefined function tokens in the token stream.

  ## Parameters
    - tokens: List of Token structs

  ## Returns
    - List of Token structs with predefined functions marked
  """
  def build_tokens(tokens) do
    Enum.map(tokens, fn token ->
      if token.type == :reserved and token.string in @predef_functions do
        %{token | type: :predef}
      else
        token
      end
    end)
  end
end
