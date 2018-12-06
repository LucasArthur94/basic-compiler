require 'aasm'
require 'linked-list'
require_relative '../helpers/token'
require_relative '../helpers/parser_error'

include AASM
include LinkedList

class PredefRecognizer
  def initialize(tokens)
    @tokens = tokens
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    token_stack = []

    @tokens.each do |classified_token|
      case classified_token.type
      when :reserved
        if %w[SIN COS TAN ATN EXP ABS LOG SQR INT RND].include? classified_token.string
          classified_token.type = :predef
          tokenized_lines.push(classified_token)
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
