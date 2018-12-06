require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/parser_error'

include AASM
include LinkedList

class DimRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  aasm do
    state :idle, initial: true
    state :dim, :dim_component, :comma

    event :recognize_dim do
      transitions from: [:idle], to: :dim
    end

    event :recognize_dim_component do
      transitions from: [:dim, :comma], to: :dim_component
    end

    event :recognize_comma do
      transitions from: [:dim_component], to: :comma
    end

    event :finish_dim do
      transitions from: [:dim_component], to: :idle
    end

    event :reset do
      transitions from: [:idle, :dim, :dim_component, :comma], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :reserved
        if self.idle?
          if classified_token.string == "DIM"
            self.recognize_dim
            token_stack.push(classified_token)
          else
            tokenized_lines.push(classified_token)
          end
        elsif self.dim_component?
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :dim, token_stack))
          token_stack = []
          if classified_token.string == "DIM"
            self.recognize_dim
            token_stack.push(classified_token)
          else
            self.reset
          end
        else
          raise ParserError.new, "erro na construção de DIM"
        end
      when :dim_component
        if self.idle?
          classified_token.child_tokens.each { |token| tokenized_lines.push(token) }
        elsif self.dim_component?
          self.finish_dim
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :dim, token_stack))
          token_stack = []
          classified_token.child_tokens.each { |token| tokenized_lines.push(token) }
        elsif self.comma? || self.dim?
          token_stack.push(classified_token)
          self.recognize_dim_component
        end
      when :special
        if classified_token.string == ","
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.dim_component?
            token_stack.push(classified_token)
            self.recognize_comma
          else
            raise ParserError.new, "erro na construção de DIM"
          end
        else
          if self.idle?
            tokenized_lines.push(classified_token)
          elsif self.dim_component?
            self.finish_dim
            tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :dim, token_stack))
            token_stack = []
            tokenized_lines.push(classified_token)
          else
            raise ParserError.new, "erro na construção de DIM"
          end
        end
      else
        if self.idle?
          tokenized_lines.push(classified_token)
        elsif self.dim_component?
          self.finish_dim
          tokenized_lines.push(Token.new(build_string_by_tokens(token_stack), :dim, token_stack))
          token_stack = []
          tokenized_lines.push(classified_token)
        else
          raise ParserError.new, "erro na construção de DIM"
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
