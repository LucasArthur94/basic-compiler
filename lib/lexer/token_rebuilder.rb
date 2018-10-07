require 'aasm'
require_relative '../helpers/token'

include AASM

class TokenRebuilder
  def initialize(tokens_classified_per_line)
    @tokens_classified_per_line = tokens_classified_per_line
  end

  aasm do
    state :idle, initial: true
    state :read_token, :rebuild_token

    event :rebuilding_token do
        transitions from: [:idle, :read_token, :rebuild_token], to: :rebuild_token
    end

    event :bypass_token do
        transitions from: [:idle, :read_token, :rebuild_token], to: :read_token
    end

    event :reset_token_reading do
        transitions from: [:read_token, :rebuild_token], to: :idle
    end
  end

  def rebuild_tokens
    retokenized_lines = LinkedList::List.new

    @tokens_classified_per_line.each do |line|
      retokenized_lines.push(tokenize_line(line))
    end

    retokenized_lines
  end

  private

  def tokenize_line(line)
    retokenized_line = LinkedList::List.new

    rebuilded_token = ""

    line.each do |classified_token|
        case classified_token.string
        when "DEF"
            rebuilded_token += classified_token.string
            self.rebuilding_token
        when "GO"
            rebuilded_token += classified_token.string
            self.rebuilding_token
        when "FN"
            rebuilded_token += classified_token.string
            retokenized_line.push(Token.new(rebuilded_token, :special))
            rebuilded_token = ""
            self.bypass_token
        when "TO"
            rebuilded_token += classified_token.string
            retokenized_line.push(Token.new(rebuilded_token, :special))
            rebuilded_token = ""
            self.bypass_token
        when "<"
            rebuilded_token += classified_token.string
            self.rebuilding_token
        when ">"
            if self.rebuild_token?
                rebuilded_token += classified_token.string
                retokenized_line.push(Token.new(rebuilded_token, :special))
                rebuilded_token = ""
                self.bypass_token
            else
                rebuilded_token += classified_token.string
                self.rebuilding_token
            end
        when "="
            if self.rebuild_token?
                rebuilded_token += classified_token.string
                retokenized_line.push(Token.new(rebuilded_token, :special))
                rebuilded_token = ""
                self.bypass_token
            else
                retokenized_line.push(classified_token)
                self.bypass_token
            end
        when " "
            if self.rebuild_token?
                rebuilded_token += classified_token.string
                self.rebuilding_token
            else
                self.bypass_token
            end
        else
            unless rebuilded_token.empty?
                retokenized_line.push(Token.new(rebuilded_token, :special))
                rebuilded_token = ""
            end
            retokenized_line.push(classified_token)
            self.bypass_token
        end
    end
    self.reset_token_reading
    retokenized_line
  end

end
