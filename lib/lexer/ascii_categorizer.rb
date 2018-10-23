require 'aasm'
require 'linked-list'
require_relative '../helpers/classified_char'
require_relative '../helpers/lexer_automatas'

include AASM
include LinkedList
include LexerAutomatas

class AsciiCategorizer
  def initialize(chars_per_line)
    @chars_per_line = chars_per_line
  end

  aasm do
    state :sleeping, initial: true
    state :reading, :reading_line, :reading_char, :finishing_char, :finishing_line, :finishing

    event :read do
      transitions from: :sleeping, to: :reading
    end

    event :read_line do
      transitions from: [:reading, :finishing_line], to: :reading_line
    end

    event :read_char do
        transitions from: [:reading_line, :finishing_char], to: :reading_char
    end

    event :finish_char do
        transitions from: :reading_char, to: :finishing_char
    end

    event :finish_line do
      transitions from: :finishing_char, to: :finishing_line
    end

    event :finish do
      transitions from: :finishing_line, to: :finishing
    end

    event :reset do
      transitions from: [:reading, :reading_line, :reading_char, :finishing_char, :finishing_line, :finishing], to: :sleeping
    end
  end

  def classify_char_all_lines
    self.read

    classified_lines = LinkedList::List.new

    @chars_per_line.each do |line|
      classified_lines.push(classify_line(line))
    end

    self.finish
    classified_lines
  end

  private

  def classify_line(line)
    self.read_line

    classified_line = LinkedList::List.new

    line.each do |char|
      classified_line.push(classify_char(char))
    end

    self.finish_line
    classified_line
  end

  def classify_char(char)
    self.read_char

    if char =~ LexerAutomatas::DELIMITER
        type = :delimiter
        util = false
    elsif char =~ LexerAutomatas::LETTER
        type = :letter
        util = true
    elsif char =~ LexerAutomatas::DIGIT
        type = :digit
        util = true
    elsif char =~ LexerAutomatas::SPECIAL
        type = :special
        util = true
    else
        type = :letter
        util = true
    end

    classified_char = ClassifiedChar.new(char, type, util)

    self.finish_char
    classified_char
  end
end
