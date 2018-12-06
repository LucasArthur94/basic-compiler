require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class ClearDelimiter
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :delimiter

    event :recognize_delimiter do
      transitions from: [:idle], to: :delimiter
    end

    event :recognize_token do
      transitions from: [:delimiter], to: :idle
    end

    event :reset do
      transitions from: [:idle, :delimiter], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    @tokens.each do |classified_token|
      case classified_token.type
      when :delimiter
        if classified_token.string != "\n"
          next
        else
          tokenized_lines.push(classified_token)
        end
      else
        tokenized_lines.push(classified_token)
      end
    end

    tokenized_lines
  end

end
