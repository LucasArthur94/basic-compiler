require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class RemBuilder
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :recognizing, :recognized

    event :recognize_R do
      transitions from: [:idle], to: :recognizing
    end

    event :recognize_E do
      transitions from: [:recognizing], to: :recognizing
    end

    event :recognize_M do
      transitions from: [:recognizing], to: :recognized
    end

    event :finishing_rem do
      transitions from: [:recognized], to: :idle
    end

    event :cancel_recognizing do
      transitions from: [:idle, :recognizing], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.string
      when "R"
        if self.idle?
          token_stack.push(classified_token)
          self.recognize_R
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          tokenized_lines.push(classified_token)
          token_stack = []
        end
      when "E"
        if self.recognizing?
          token_stack.push(classified_token)
          self.recognize_E
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          tokenized_lines.push(classified_token)
          token_stack = []
        end
      when "M"
        if self.recognizing?
          token_stack.push(classified_token)
          self.recognize_M
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          tokenized_lines.push(classified_token)
          token_stack = []
        end
      else
        if self.recognized?
          if classified_token.string != "\n"
            token_stack.push(classified_token)
          else
            self.finishing_rem
            merged_token = ""
            token_stack.map do |token|
              merged_token += token.string
            end
            tokenized_lines.push(Token.new(merged_token, :rem))
            tokenized_lines.push(classified_token)
            token_stack = []
          end
        else
          token_stack.each { |token| tokenized_lines.push(token) }
          tokenized_lines.push(classified_token)
          token_stack = []
        end
      end
    end

    tokenized_lines
  end

end
