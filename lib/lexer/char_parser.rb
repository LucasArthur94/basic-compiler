require 'aasm'

include AASM

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
    parsed_lines = @lines.map do |line|
      parse_char(line)
    end
    self.finish
    parsed_lines
  end

  private

  def parse_char(line)
    self.read_line
    chars = line.split("")
    self.finish_line
    chars
  end
end
