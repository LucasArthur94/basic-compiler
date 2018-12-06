class Token
    attr_accessor :string, :type, :child_tokens

    def initialize(string, type, child_tokens)
        @string = string
        @type = type
        @child_tokens = child_tokens
    end
end
