require_relative 'lib/lexer/file_reader'

require_relative 'lib/lexer/line_parser'

require_relative 'lib/lexer/char_parser'

require_relative 'lib/lexer/ascii_categorizer'

require_relative 'lib/lexer/string_builder'
require_relative 'lib/lexer/rem_builder'
require_relative 'lib/lexer/clear_delimiter'
require_relative 'lib/lexer/reserved_keywords'
require_relative 'lib/lexer/identifier'
require_relative 'lib/lexer/integer'
require_relative 'lib/lexer/number_recognizer'

def main
  # Nível 0 de abstração
  file_reader = FileReader.new(ARGV[0])
  content = file_reader.read_file

  # Nível 1 de abstração
  line_parser = LineParser.new(content)
  lines = line_parser.parse_lines

  # Nível 2 de abstração
  char_parser = CharParser.new(lines)
  chars_per_line = char_parser.parse_char_all_lines

  # Níveis 3 e 4 de abstração
  char_classifier = AsciiCategorizer.new(chars_per_line)
  chars_classified_per_line = char_classifier.classify_char_all_lines

  # Nível 5 de abstração - vários motores de eventos
  # Classificação de Strings
  string_builder = StringBuilder.new(chars_classified_per_line)
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

  # Inteiros
  integer_recognizer = IntegerRecognizer.new(tokens_per_line)
  tokens_per_line = integer_recognizer.build_tokens

  # Números
  number_recognizer = NumberRecognizer.new(tokens_per_line)
  tokens_per_line = number_recognizer.build_tokens

  # Identificadores
  identifier = Identifier.new(tokens_per_line)
  tokens_per_line = identifier.build_tokens

  # Impressão dos Tokens
  tokens_per_line.each do |token|
    p "============="
    p token
  end
end

main
