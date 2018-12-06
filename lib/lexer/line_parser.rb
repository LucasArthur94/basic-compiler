require 'aasm'
require 'linked-list'

include AASM
include LinkedList

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

    simple_lines = @content.split(/(?<=\n)/)
    lines = LinkedList::List.new

    simple_lines.each do |line|
      lines.push(line)
    end

    self.finish
    lines
  end
end
