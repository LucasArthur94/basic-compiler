require 'aasm'
require 'linked-list'
require_relative '../helpers/token'

include AASM
include LinkedList

class TokenBuilder
  RESERVED_KEYWORDS = %w[LET END SIN COS TAN ATN EXP ABS LOG SQR INT
                           RND READ DATA PRINT GOTO GO TO IF THEN FOR TO
                           STEP NEXT DIM DEF FN GOSUB RETURN REM E].freeze

  def initialize(chars_classified_per_line)
    @chars_classified_per_line = chars_classified_per_line
  end

  aasm do
    state :idle, initial: true
    state :build_token, :build_special, :pass_delimiter

    event :building_token do
        transitions from: [:idle, :build_token, :build_special, :pass_delimiter], to: :build_token
    end

    event :building_special do
        transitions from: [:build_token, :build_special, :pass_delimiter], to: :build_special
    end

    event :recognize_delimiter do
        transitions from: [:build_token, :build_special, :pass_delimiter], to: :pass_delimiter
    end

    event :reset_token_reading do
        transitions from: [:build_token, :build_special, :pass_delimiter], to: :idle
    end
  end

  def build_tokens
    tokenized_lines = LinkedList::List.new

    @chars_classified_per_line.each do |line|
      tokenized_lines.push(tokenize_line(line))
    end

    tokenized_lines
  end

  private

  def is_reserved_keyword?(string)
    RESERVED_KEYWORDS.include?(string.upcase)
  end

  def tokenize_line(line)
    tokenized_line = LinkedList::List.new

    partial_token = ""

    line.each do |classified_char|
        case classified_char.type
        when :letter
            self.building_token
            partial_token += classified_char.char
        when :number
            self.building_token
            partial_token += classified_char.char
        when :special
            if self.build_token?
                if is_reserved_keyword?(partial_token)
                    tokenized_line.push(Token.new(partial_token, :reservated))
                else
                    tokenized_line.push(Token.new(partial_token, :common))
                end
                partial_token = ""
            end
            self.building_special
            tokenized_line.push(Token.new(classified_char.char, :special))
        when :delimiter
            if self.build_token?
                if is_reserved_keyword?(partial_token)
                    tokenized_line.push(Token.new(partial_token, :reservated))
                else
                    tokenized_line.push(Token.new(partial_token, :common))
                end
                partial_token = ""
            end
            self.recognize_delimiter
        end
    end
    if self.build_token?
        if is_reserved_keyword?(partial_token)
            tokenized_line.push(Token.new(partial_token, :reservated))
        else
            tokenized_line.push(Token.new(partial_token, :common))
        end
        partial_token = ""
    end
    self.reset_token_reading
    tokenized_line
  end

end
