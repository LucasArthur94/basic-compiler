require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/automata'

include AASM
include LinkedList

class TokenBuilder
  def initialize(chars_classified_per_line)
    @chars_classified_per_line = chars_classified_per_line
  end

  aasm do
    state :idle, initial: true
    state :build_token, :build_special, :pass_delimiter

    event :building_token do
        transitions from: [:idle, :build_token, :build_special, :pass_delimiter], to: :build_token
    end

    event :building_special do
        transitions from: [:idle, :build_token, :build_special, :pass_delimiter], to: :build_special
    end

    event :recognize_delimiter do
        transitions from: [:build_token, :build_special, :pass_delimiter], to: :pass_delimiter
    end

    event :reset_token_reading do
        transitions from: [:build_token, :build_special, :pass_delimiter], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    @chars_classified_per_line.each do |line|
      tokenized_lines.push(tokenize_line(line))
    end

    tokenized_lines
  end

  private

  def tokenize_line(line)
    tokenized_line = LinkedList::List.new

    partial_token = ""

    line.each do |classified_char|
      case classified_char.type
      when :letter
        self.building_token
        partial_token += classified_char.char
      when :digit
        self.building_token
        partial_token += classified_char.char
      when :special
        self.building_special
        partial_token += classified_char.char
      when :delimiter
        self.recognize_delimiter
        unless partial_token.empty?
          tokenized_line.push(check_automatas(partial_token))
          partial_token = ""
          self.reset_token_reading
        end
      end
    end

    tokenized_line.push(check_automatas(partial_token)) unless partial_token.empty?

    tokenized_line
  end

  def check_automatas(partial_token)
    special_automata = Automata.new(LexerAutomatas::SPECIAL, nil, :special)
    special_composed_automata = Automata.new(LexerAutomatas::SPECIAL_COMPOSED, nil, :special)
    reserved_automata = Automata.new(LexerAutomatas::RESERVED, nil, :reserved)
    identifier_automata = Automata.new(LexerAutomatas::IDENTIFIER, nil, :identifier)
    snum_automata = Automata.new(LexerAutomatas::SNUM, nil, :number)

    automatas = [special_automata, special_composed_automata, reserved_automata, identifier_automata, snum_automata].sort_by {|automata| automata.situation}

    automatas.each { |automata| automata.verify_situation(partial_token) }

    valid_automatas = automatas.select { |automata| automata.situation == partial_token }

    if valid_automatas.length == 1
      Token.new(partial_token, valid_automatas.first.token_type)
    else
      Token.new(partial_token, :undefined)
    end
  end

end
