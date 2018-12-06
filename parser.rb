require_relative 'lib/parser/gosub'
require_relative 'lib/parser/goto'
require_relative 'lib/parser/predef'
require_relative 'lib/parser/data'
require_relative 'lib/parser/next'
require_relative 'lib/parser/dim_component'
require_relative 'lib/parser/dim'

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def execute_parser
    # Gosub
    gosub_recognizer = GosubRecognizer.new(@tokens)
    tokens_per_line = gosub_recognizer.build_tokens

    # Goto
    goto_recognizer = GotoRecognizer.new(tokens_per_line)
    tokens_per_line = goto_recognizer.build_tokens

    # Predef
    predef_recognizer = PredefRecognizer.new(tokens_per_line)
    tokens_per_line = predef_recognizer.build_tokens

    # Data
    data_recognizer = DataRecognizer.new(tokens_per_line)
    tokens_per_line = data_recognizer.build_tokens

    # Next
    next_recognizer = NextRecognizer.new(tokens_per_line)
    tokens_per_line = next_recognizer.build_tokens

    # Dim component, created to simplify Dim
    dim_component_recognizer = DimComponentRecognizer.new(tokens_per_line)
    tokens_per_line = dim_component_recognizer.build_tokens

    # Dim
    dim_recognizer = DimRecognizer.new(tokens_per_line)
    tokens_per_line = dim_recognizer.build_tokens

    # tokens_per_line
  end
end
