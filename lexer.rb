require_relative 'lib/lexer/string_builder'
require_relative 'lib/lexer/rem_builder'
require_relative 'lib/lexer/clear_delimiter'
require_relative 'lib/lexer/reserved_keywords'
require_relative 'lib/lexer/identifier'
require_relative 'lib/lexer/integer'
require_relative 'lib/lexer/number_recognizer'
require_relative 'lib/lexer/signal_number_recognizer'

class Lexer
  def initialize(chars_classified_per_line)
    @chars_classified_per_line = chars_classified_per_line
  end

  def execute_lexer
    # Classificação de Strings
    string_builder = StringBuilder.new(@chars_classified_per_line)
    tokens_per_line = string_builder.build_tokens

    # Classificação de REM
    rem_builder = RemBuilder.new(tokens_per_line)
    tokens_per_line = rem_builder.build_tokens

    # Limpeza dos Delimitadores em Branco
    clear_delimiter = ClearDelimiter.new(tokens_per_line)
    tokens_per_line = clear_delimiter.build_tokens

    # Identificador de palavras reservadas
    reserved_keywords = ReservedKeywords.new(tokens_per_line)
    tokens_per_line = reserved_keywords.build_tokens

    # Identificadores
    identifier = Identifier.new(tokens_per_line)
    tokens_per_line = identifier.build_tokens

    # Inteiros
    integer_recognizer = IntegerRecognizer.new(tokens_per_line)
    tokens_per_line = integer_recognizer.build_tokens

    # Números
    number_recognizer = NumberRecognizer.new(tokens_per_line)
    tokens_per_line = number_recognizer.build_tokens

    # Números com Sinal
    signal_number_recognizer = SignalNumberRecognizer.new(tokens_per_line)
    tokens_per_line = signal_number_recognizer.build_tokens

    tokens_per_line
  end
end
