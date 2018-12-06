require_relative 'lib/lexer/file_reader'

require_relative 'lib/lexer/line_parser'

require_relative 'lib/lexer/char_parser'

require_relative 'lib/lexer/ascii_categorizer'

require_relative 'lexer'

require_relative 'parser'

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

  # Nível 5 e 6 de abstração - vários motores de eventos dentro
  lexer = Lexer.new(chars_classified_per_line)
  tokens_per_line = lexer.execute_lexer

  # Nível 7 de abstração - vários motores de eventos dentro
  parser = Parser.new(tokens_per_line)
  tokens_per_line = parser.execute_parser

  # Impressão dos Tokens
  tokens_per_line.each do |token|
    p "============="
    p token
  end
end

main
