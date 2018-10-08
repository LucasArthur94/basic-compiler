require 'aasm'
require 'linked-list'

include AASM
include LinkedList

class CharParser
  def initialize(lines)
    @lines = lines
  end

  aasm do
    state :sleeping, initial: true
    state :reading, :reading_line, :finishing_line, :finishing

    event :read do
      transitions from: :sleeping, to: :reading
    end

    event :read_line do
      transitions from: [:reading, :finishing_line], to: :reading_line
    end

    event :finish_line do
      transitions from: :reading_line, to: :finishing_line
    end

    event :finish do
      transitions from: :finishing_line, to: :finishing
    end

    event :reset do
      transitions from: [:reading, :reading_line, :finishing_line, :finishing], to: :sleeping
    end
  end

  def parse_char_all_lines
    self.read

    lines_and_chars = LinkedList::List.new

    @lines.each do |line|
      lines_and_chars.push(parse_char(line))
    end
    self.finish
    lines_and_chars
  end

  private

  def parse_char(line)
    self.read_line

    chars = LinkedList::List.new

    chars_list = line.split("")

    chars_list.each do |char|
      chars.push(char)
    end

    self.finish_line
    chars
  end
end
