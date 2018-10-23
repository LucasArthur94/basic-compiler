require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/invalid_token_exception'

include AASM
include LinkedList

class TokenRebuilder
  def initialize(tokens_classified_per_line)
    @tokens_classified_per_line = tokens_classified_per_line
  end

  aasm do
    state :idle, initial: true
    state :read_token, :rebuild_token

    event :rebuilding_token do
        transitions from: [:idle, :read_token, :rebuild_token], to: :rebuild_token
    end

    event :bypass_token do
        transitions from: [:idle, :read_token, :rebuild_token], to: :read_token
    end

    event :reset_token_reading do
        transitions from: [:idle, :read_token, :rebuild_token], to: :idle
    end
  end

  def rebuild_tokens
    retokenized_lines = LinkedList::List.new

    @tokens_classified_per_line.each do |line|
      retokenized_lines.push(retokenize_line(line))
    end

    retokenized_lines
  end

  private

  def retokenize_line(line)
    undefined_tokens = generate_undefined_tokens(line)

    classify_undefined_tokens!(undefined_tokens) if undefined_tokens

    read_undefined = false

    line.each do |classified_token|
      next unless undefined_tokens
      if classified_token.type == :undefined
        line.delete(classified_token)
        read_undefined = true
        next
      elsif read_undefined
        selected_token = undefined_tokens.shift
        if selected_token.type != :undefined
          line.insert(selected_token, before: classified_token)
        else
          new_tokens = parse_undefined_token(selected_token)
          new_tokens.each do |new_token|
            line.insert(new_token, before: classified_token)
          end
        end
        read_undefined = false
      end
    end

    if read_undefined
      selected_token = undefined_tokens.shift
      if selected_token.type != :undefined
        line.insert(selected_token, after: line.last)
      else
        new_tokens = parse_undefined_token(selected_token)
        new_tokens.each do |new_token|
          line.insert(new_token, after: line.last)
        end
      end
      read_undefined = false
    end

    self.reset_token_reading
    line
  end

  def generate_undefined_tokens(line)
    undefined_tokens = []

    string_undefined_stack = ""

    line.each do |classified_token|
      if classified_token.type == :undefined
        if string_undefined_stack.empty?
          string_undefined_stack += classified_token.string
        else
          string_undefined_stack += ("\ " + classified_token.string)
        end
      elsif !string_undefined_stack.empty?
        undefined_tokens.push(Token.new(string_undefined_stack, :undefined))
        string_undefined_stack = ""
      end
    end

    if !string_undefined_stack.empty?
      undefined_tokens.push(Token.new(string_undefined_stack, :undefined))
    end

    undefined_tokens
  end

  def classify_undefined_tokens!(undefined_tokens)
    composed_automata = Automata.new(LexerAutomatas::COMPOSED, nil, :composed)

    undefined_tokens.each do |token|
      composed_automata.verify_situation(token.string)

      if composed_automata.situation == token.string
        token.type = composed_automata.token_type
      end
    end
  end

  def parse_undefined_token(selected_token)
    new_tokens = LinkedList::List.new

    identifier_automata = Automata.new(LexerAutomatas::IDENTIFIER, nil, :identifier)
    special_automata = Automata.new(LexerAutomatas::SPECIAL, nil, :special)
    snum_automata = Automata.new(LexerAutomatas::SNUM, nil, :number)

    automatas = [special_automata, identifier_automata, snum_automata].sort_by {|automata| automata.situation}

    new_strings = selected_token.string.split("")

    new_strings.each do |string|
      next if string == "\ "
      automatas.each { |automata| automata.verify_situation(string) }

      valid_automatas = automatas.select { |automata| automata.situation == string }

      new_tokens.push(Token.new(string, valid_automatas.first.token_type))
    end

    new_tokens
  end

end
