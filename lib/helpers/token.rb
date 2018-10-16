class Token
    attr_reader :string, :type

    def initialize(string, type)
        @string = string
        @type = type
    end
end
