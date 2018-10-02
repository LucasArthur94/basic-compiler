require 'aasm'

include AASM

class FileReader
  def initialize(filename)
    @filename = filename
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

  def read_file
    self.read
    file = File.open(@filename, 'r')
    data = file.read
    file.close
    self.finish
    data
  end
end
