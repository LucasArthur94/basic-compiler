require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class SignalNumberRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :recognized_signal

    event :recognize_signal do
      transitions from: [:idle], to: :recognized_signal
    end

    event :finish_special_number do
      transitions from: [:recognized_signal], to: :idle
    end

    event :cancel_recognizing do
      transitions from: [:idle, :recognized_signal], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :special
        if classified_token.string == "+" || classified_token.string == "-"
          if self.idle?
            token_stack.push(classified_token)
            self.recognize_signal
          else
            token_stack.each { |token| tokenized_lines.push(token) }
            token_stack = []
            token_stack.push(classified_token)
          end
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          tokenized_lines.push(classified_token)
        end
      when :number
        if self.recognized_signal?
          token_stack.push(classified_token)
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :signed_number, token_stack))
          token_stack = []
          self.finish_special_number
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          tokenized_lines.push(classified_token)
        end
      else
        self.cancel_recognizing
        token_stack.each { |token| tokenized_lines.push(token) }
        token_stack = []
        tokenized_lines.push(classified_token)
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
