require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/parser_error'

include AASM
include LinkedList

class GosubRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :gosub

    event :recognize_gosub do
      transitions from: [:idle], to: :gosub
    end

    event :finish_gosub do
      transitions from: [:gosub], to: :idle
    end

    event :reset do
      transitions from: [:idle, :gosub], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :reserved
        if self.idle?
          if classified_token.string == "GOSUB"
            self.recognize_gosub
            token_stack.push(classified_token)
          else
            tokenized_lines.push(classified_token)
          end
        elsif self.gosub?
          raise ParserError.new, "erro na construção de GOSUB"
        end
      when :integer
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.gosub?
          token_stack.push(classified_token)
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :integer, token_stack))
          token_stack = []
          self.finish_gosub
        end
      else
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.gosub?
          raise ParserError.new, "erro na construção de GOSUB"
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
