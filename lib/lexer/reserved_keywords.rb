require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include LinkedList

class ReservedKeywords
  def initialize(tokens)
    @tokens = tokens
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    reserved_stack = []

    reserved_words = %w[ABS ATN COS DATA
                        DEF DIM END EXP
                        FN FOR GO GOSUB
                        GOTO IF INT LET
                        LOG NEXT PRINT READ
                        REM RETURN RND SIN
                        SQR STEP TAN THEN TO]

    @tokens.each do |classified_token|
      case classified_token.type
      when :letter
        reserved_stack.push(classified_token)
        new_string = build_string_by_tokens(reserved_stack)
        if reserved_words.include? new_string
          tokenized_lines.push(Token.new(new_string, :reserved))
          reserved_stack = []
        end
      else
        reserved_stack.each { |token| tokenized_lines.push(token) }
        tokenized_lines.push(classified_token)
        reserved_stack = []
      end
    end

    reserved_stack.each { |token| tokenized_lines.push(token) }

    tokenized_lines
  end

  def build_string_by_tokens(token_list)
    texts = token_list.map do |token|
      token.string
    end
    texts.reduce(:+)
  end

end
