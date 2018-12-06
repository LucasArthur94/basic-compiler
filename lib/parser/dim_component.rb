require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/parser_error'

include AASM
include LinkedList

class DimComponentRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :letter, :open_parenthesis, :digit, :comma, :close_parenthesis

    event :recognize_letter do
      transitions from: [:idle], to: :letter
    end

    event :recognize_open do
      transitions from: [:letter], to: :open_parenthesis
    end

    event :recognize_digit do
      transitions from: [:open_parenthesis, :comma], to: :digit
    end

    event :recognize_comma do
      transitions from: [:digit], to: :comma
    end

    event :recognize_close do
      transitions from: [:digit], to: :close_parenthesis
    end

    event :finish_dim_component do
      transitions from: [:close_parenthesis], to: :idle
    end

    event :reset do
      transitions from: [:idle, :letter, :open_parenthesis, :digit, :comma, :close_parenthesis], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :letter
        if self.idle?
          token_stack.push(classified_token)
          self.recognize_letter
        else
          self.reset
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          token_stack.push(classified_token)
          self.recognize_letter
        end
      when :special
        if classified_token.string == "("
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.letter?
            token_stack.push(classified_token)
            self.recognize_open
          else
            self.reset
            token_stack.each { |token| tokenized_lines.push(token) }
            token_stack = []
            tokenized_lines.push(classified_token)
          end
        elsif classified_token.string == ")"
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.digit?
            self.recognize_close
            token_stack.push(classified_token)
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :dim_component, token_stack))
            token_stack = []
            self.finish_dim_component
          else
            self.reset
            token_stack.each { |token| tokenized_lines.push(token) }
            token_stack = []
            tokenized_lines.push(classified_token)
          end
        elsif classified_token.string == ","
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.digit?
            token_stack.push(classified_token)
            self.recognize_comma
          else
            self.reset
            token_stack.each { |token| tokenized_lines.push(token) }
            token_stack = []
            tokenized_lines.push(classified_token)
          end
        else
          self.reset
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          tokenized_lines.push(classified_token)
        end
      when :integer
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif (self.open_parenthesis? || self.comma?) && classified_token.string.length == 1
          token_stack.push(classified_token)
          self.recognize_digit
        else
          self.reset
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          tokenized_lines.push(classified_token)
        end
      else
        if self.idle?
          tokenized_lines.push(classified_token)
        else
          self.reset
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          tokenized_lines.push(classified_token)
        end
      end
    end

    tokenized_lines
  end


  def build_string_by_tokens(token_list)
    texts = token_list.map do |token|
      token.string
    end
    texts.reduce(:+)
  end
end
