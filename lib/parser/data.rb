require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/parser_error'

include AASM
include LinkedList

class DataRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :data, :snum, :comma

    event :recognize_data do
      transitions from: [:idle], to: :data
    end

    event :recognize_snum do
      transitions from: [:data, :comma], to: :snum
    end

    event :recognize_comma do
      transitions from: [:snum], to: :comma
    end

    event :reset do
      transitions from: [:idle, :data, :snum, :comma], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :reserved
        if classified_token.string == "DATA"
          if self.idle?
            token_stack.push(classified_token)
            self.recognize_data
          elsif self.snum?
            self.reset
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :data, token_stack))
            token_stack = []
            token_stack.push(classified_token)
            self.recognize_data
          else
            raise ParserError.new, "erro na construção de DATA"
          end
        else
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.snum?
            self.reset
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :data, token_stack))
            token_stack = []
            tokenized_lines.push(classified_token)
          else
            raise ParserError.new, "erro na construção de DATA"
          end
        end
      when :integer, :number, :signed_number
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.data? || self.comma?
          token_stack.push(classified_token)
          self.recognize_snum
        elsif self.snum?
          self.reset
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :data, token_stack))
          token_stack = []
          tokenized_lines.push(classified_token)
        else
          raise ParserError.new, "erro na construção de DATA"
        end
      when :special
        if classified_token.string == ","
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.snum?
            token_stack.push(classified_token)
            self.recognize_comma
          else
            raise ParserError.new, "erro na construção de DATA"
          end
        else
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.snum?
            self.reset
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :data, token_stack))
            token_stack = []
            tokenized_lines.push(classified_token)
          else
            raise ParserError.new, "erro na construção de DATA"
          end
        end
      else
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.snum?
          self.reset
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :data, token_stack))
          token_stack = []
          tokenized_lines.push(classified_token)
        else
          raise ParserError.new, "erro na construção de DATA"
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
