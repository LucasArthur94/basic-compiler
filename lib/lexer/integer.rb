require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class IntegerRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :recognizing

    event :recognize do
      transitions from: [:idle, :recognizing], to: :recognizing
    end

    event :finishing_integer do
      transitions from: [:recognizing], to: :idle
    end

    event :cancel_recognizing do
      transitions from: [:idle, :recognizing], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :digit
        self.recognize
        token_stack.push(classified_token)
      else
        if self.recognizing?
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :integer, token_stack))
          token_stack = []
          self.finishing_integer
        end
        tokenized_lines.push(classified_token)
      end
    end

    if self.recognizing?
      tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :integer, token_stack))
      token_stack = []
      self.finishing_integer
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
