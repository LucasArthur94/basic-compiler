require_relative 'lib/lexer/file_reader'
require_relative 'lib/lexer/line_parser'
require_relative 'lib/lexer/char_parser'
require_relative 'lib/lexer/ascii_categorizer'
require_relative 'lib/lexer/token_builder'
require_relative 'lib/lexer/token_rebuilder'

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

  # Nível 5 de abstração
  token_builder = TokenBuilder.new(chars_classified_per_line)
  tokens_per_line = token_builder.build_tokens

  # Nível 6 de abstração
  token_rebuilder = TokenRebuilder.new(tokens_per_line)
  tokens_reclassified_per_line = token_rebuilder.rebuild_tokens

  # Impressão dos Tokens
  tokens_reclassified_per_line.each do |line|
    p "============="
    p "Linha #{tokens_reclassified_per_line.to_a.index(line) + 1}"
    line.each { |token| p token }
  end
end

main
