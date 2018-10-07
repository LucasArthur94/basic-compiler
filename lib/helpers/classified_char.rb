class ClassifiedChar
    attr_reader :type, :char

    def initialize(char, type, util)
        @char = char
        @type = type
        @util = util
    end
end
