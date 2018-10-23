class Token
    attr_accessor :string, :type

    def initialize(string, type)
        @string = string
        @type = type
    end
end
