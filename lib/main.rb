require_relative 'lexer/file_reader'
require_relative 'lexer/line_parser'
require_relative 'lexer/char_parser'
require_relative 'lexer/ascii_categorizer'
require_relative 'lexer/token_builder'

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

  # # Nível 5 de abstração
  token_builder = TokenBuilder.new(chars_classified_per_line)
  tokens_per_line = token_builder.build_tokens

  tokens_per_line.each do |line|
    line.each { |char| p char }
    p "\n"
  end
end

main
