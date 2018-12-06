require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class Identifier
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :recognized

    event :recognize_letter do
      transitions from: [:idle], to: :recognized
    end

    event :recognize_digit do
      transitions from: [:recognized], to: :recognized
    end

    event :finishing_identifier do
      transitions from: [:recognized], to: :idle
    end

    event :cancel_recognizing do
      transitions from: [:idle, :recognized], to: :idle
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
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          self.finishing_identifier
          token_stack.push(classified_token)
          self.recognize_letter
        end
      when :integer
        if self.idle?
          tokenized_lines.push(classified_token)
        else
          self.recognize_digit
          token_stack.push(classified_token)
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :identifier))
          token_stack = []
          self.finishing_identifier
        end
      else
        if self.idle?
          tokenized_lines.push(classified_token)
        else
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          self.finishing_identifier
          tokenized_lines.push(classified_token)
        end
      end
    end

    token_stack.each { |token| tokenized_lines.push(token) }

    tokenized_lines
  end

  def build_string_by_tokens(token_list)
    texts = token_list.map do |token|
      token.string
    end
    texts.reduce(:+)
  end

end
