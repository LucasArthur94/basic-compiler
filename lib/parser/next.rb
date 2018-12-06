require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/parser_error'

include AASM
include LinkedList

class NextRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :next, :letter

    event :recognize_next do
      transitions from: [:idle], to: :next
    end

    event :recognize_letter do
      transitions from: [:next], to: :letter
    end

    event :finish_goto do
      transitions from: [:letter], to: :idle
    end

    event :reset do
      transitions from: [:idle, :next, :letter], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :reserved
        if self.idle?
          if classified_token.string == "NEXT"
            self.recognize_next
            token_stack.push(classified_token)
          else
            tokenized_lines.push(classified_token)
          end
        elsif self.letter?
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :next, token_stack))
          token_stack = []
          if classified_token.string == "NEXT"
            self.recognize_next
            token_stack.push(classified_token)
          else
            self.reset
          end
        else
          raise ParserError.new, "erro na construção de GOTO"
        end
      when :letter
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.next?
          token_stack.push(classified_token)
          self.recognize_letter
        elsif self.letter?
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :next, token_stack))
          token_stack = []
          tokenized_lines.push(classified_token)
          self.reset
        else
          raise ParserError.new, "erro na construção de GOTO"
        end
      when :integer
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.letter? && classified_token.length == 1
          token_stack.push(classified_token)
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :next, token_stack))
          token_stack = []
          self.reset
        else
          raise ParserError.new, "erro na construção de GOTO"
        end
      else
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.letter?
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :next, token_stack))
          token_stack = []
          tokenized_lines.push(classified_token)
          self.reset
        else
          raise ParserError.new, "erro na construção de GOTO"
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
