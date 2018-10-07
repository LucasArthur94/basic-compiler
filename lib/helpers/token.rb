class Token
    attr_reader :string

    def initialize(string, type)
        @string = string
        @type = type
    end
end
