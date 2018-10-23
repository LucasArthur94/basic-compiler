class Automata
    attr_accessor :automata_regex, :situation, :token_type

    def initialize(automata_regex, situation, token_type)
        @automata_regex = automata_regex
        @situation = situation
        @token_type = token_type
    end

    def verify_situation(partial_token_string)
        match_string = partial_token_string.match(@automata_regex)
        # print "partial_token_string = #{partial_token_string}\n"
        # print "automata_regex = #{automata_regex}\n"
        # p match_string[0] if match_string
        @situation = match_string[0] if match_string
    end
end
