require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/automata'

include AASM
include LinkedList

class StringBuilder
  def initialize(chars_classified_per_line)
    @chars_classified_per_line = chars_classified_per_line
  end

  aasm do
    state :idle, initial: true
    state :build_string

    event :building_string do
      transitions from: [:idle], to: :build_string
    end

    event :finishing_string do
      transitions from: [:build_string], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    partial_string = ""

    @chars_classified_per_line.each do |line|
      line.each do |classified_char|
        case classified_char.char
        when "\""
          if self.build_string?
            partial_string += classified_char.char
            tokenized_lines.push(Token.new(partial_string, :string))
            partial_string = ""
            self.finishing_string
          else
            partial_string += classified_char.char
            self.building_string
          end
        else
          if self.build_string?
            partial_string += classified_char.char
          else
            tokenized_lines.push(Token.new(classified_char.char, classified_char.type))
          end
        end
      end
    end

    tokenized_lines
  end

end
