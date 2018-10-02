require 'aasm'

include AASM

class LineParser
  def initialize(content)
    @content = content
  end

  aasm do
    state :sleeping, initial: true
    state :reading, :finishing

    event :read do
      transitions from: :sleeping, to: :reading
    end

    event :finish do
      transitions from: :reading, to: :finishing
    end

    event :reset do
      transitions from: [:reading, :finishing], to: :sleeping
    end
  end

  def parse_lines
    self.read
    lines = @content.split("\n")
    self.finish
    lines
  end
end
