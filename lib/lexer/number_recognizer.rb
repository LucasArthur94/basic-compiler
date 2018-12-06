require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class NumberRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :recognized_int, :recognized_dot, :recognized_E, :recognized_signal, :partial_recognition

    event :recognize_int do
      transitions from: [:idle], to: :recognized_int
    end

    event :recognize_dot do
      transitions from: [:idle], to: :recognized_dot
    end

    event :recognize_cientific do
      transitions from: [:partial_recognition], to: :recognized_E
    end

    event :recognize_signal do
      transitions from: [:recognized_E], to: :recognized_signal
    end

    event :standby do
      transitions from: [:recognized_int, :recognized_dot], to: :partial_recognition
    end

    event :finishing_number do
      transitions from: [:partial_recognition, :recognized_E, :recognized_signal], to: :idle
    end

    event :cancel_recognizing do
      transitions from: [:idle, :recognized_int, :recognized_dot, :partial_recognition, :recognized_E], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :integer
        if self.idle?
          self.recognize_int
          token_stack.push(classified_token)
        elsif self.recognized_dot?
          token_stack.push(classified_token)
          self.standby
        elsif self.recognized_E? || self.recognized_signal?
          self.finishing_number
          token_stack.push(classified_token)
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :number))
          token_stack = []
        elsif self.partial_recognition?
          if token_stack.first.type == :integer
            token_stack.push(classified_token)
          else
            self.finishing_number
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :number))
            token_stack = []
            tokenized_lines.push(classified_token)
          end
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          token_stack.push(classified_token)
          self.recognize_int
        end
      when :special
        if classified_token.string == "."
          if self.idle?
            self.recognize_dot
            token_stack.push(classified_token)
          elsif self.recognized_int?
            token_stack.push(classified_token)
            self.standby
          end
        elsif classified_token.string == "+" || classified_token.string == "-"
          if self.partial_recognition?
            self.finishing_number
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :number))
            token_stack = []
            tokenized_lines.push(classified_token)
          elsif self.recognized_E?
            token_stack.push(classified_token)
            self.recognize_signal
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
      when :letter
        if self.partial_recognition?
          if classified_token.string == "E"
            token_stack.push(classified_token)
            self.recognize_cientific
          else
            self.finishing_number
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :number))
            token_stack = []
            tokenized_lines.push(classified_token)
          end
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
          tokenized_lines.push(classified_token)
        end
      else
        if self.partial_recognition?
          self.finishing_number
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :number))
        else
          self.cancel_recognizing
          token_stack.each { |token| tokenized_lines.push(token) }
          token_stack = []
        end
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
