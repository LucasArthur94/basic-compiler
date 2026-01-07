defmodule BasicCompilerTest do
  use ExUnit.Case
  doctest BasicCompiler

  alias BasicCompiler.Helpers.Token

  describe "compile/1" do
    test "compiles reference.bas successfully" do
      tokens = BasicCompiler.compile("examples/reference.bas")

      assert is_list(tokens)
      assert length(tokens) > 0

      # Check for key tokens
      assert Enum.any?(tokens, fn t -> t.string == "PRINT" and t.type == :reserved end)
      assert Enum.any?(tokens, fn t -> t.string == "END" and t.type == :reserved end)
      assert Enum.any?(tokens, fn t -> t.string == "\"HELLO WORLD\"" and t.type == :string end)
    end

    test "compiles exponential.bas successfully" do
      tokens = BasicCompiler.compile("examples/exponential.bas")

      assert is_list(tokens)
      assert length(tokens) > 0

      # Check for scientific notation
      assert Enum.any?(tokens, fn t -> t.type == :signed_number end)
    end
  end

  describe "lexer stages" do
    alias BasicCompiler.Lexer.{FileReader, LineParser, CharParser, AsciiCategorizer}
    alias BasicCompiler.Lexer

    test "FileReader reads file content" do
      content = FileReader.read_file("examples/reference.bas")
      assert is_binary(content)
      assert String.contains?(content, "PRINT")
    end

    test "LineParser splits content into lines" do
      content = "10 PRINT\n20 END\n"
      lines = LineParser.parse_lines(content)
      assert length(lines) == 2
    end

    test "CharParser splits lines into characters" do
      lines = ["10 PRINT\n"]
      chars_per_line = CharParser.parse_char_all_lines(lines)
      assert is_list(chars_per_line)
      assert length(hd(chars_per_line)) == 9
    end

    test "AsciiCategorizer classifies characters" do
      chars_per_line = [["1", "0", " ", "P"]]
      classified = AsciiCategorizer.classify_char_all_lines(chars_per_line)

      assert is_list(classified)
      first_line = hd(classified)
      assert hd(first_line).type == :digit
      assert Enum.at(first_line, 2).type == :delimiter
      assert Enum.at(first_line, 3).type == :letter
    end

    test "complete lexer pipeline recognizes tokens" do
      chars_classified = [
        [
          %BasicCompiler.Helpers.ClassifiedChar{char: "1", type: :digit, util: true},
          %BasicCompiler.Helpers.ClassifiedChar{char: "0", type: :digit, util: true},
          %BasicCompiler.Helpers.ClassifiedChar{char: " ", type: :delimiter, util: false},
          %BasicCompiler.Helpers.ClassifiedChar{char: "P", type: :letter, util: true},
          %BasicCompiler.Helpers.ClassifiedChar{char: "R", type: :letter, util: true},
          %BasicCompiler.Helpers.ClassifiedChar{char: "I", type: :letter, util: true},
          %BasicCompiler.Helpers.ClassifiedChar{char: "N", type: :letter, util: true},
          %BasicCompiler.Helpers.ClassifiedChar{char: "T", type: :letter, util: true}
        ]
      ]

      tokens = Lexer.execute_lexer(chars_classified)

      assert is_list(tokens)
      assert Enum.any?(tokens, fn t -> t.string == "10" and t.type == :integer end)
      assert Enum.any?(tokens, fn t -> t.string == "PRINT" and t.type == :reserved end)
    end
  end

  describe "parser stages" do
    alias BasicCompiler.Parser

    test "recognizes GOSUB statements" do
      tokens = [
        Token.new("GOSUB", :reserved, []),
        Token.new("100", :integer, [])
      ]

      result = BasicCompiler.Parser.Gosub.build_tokens(tokens)
      assert length(result) == 1
      assert hd(result).string == "GOSUB100"
      assert hd(result).type == :integer
    end

    test "recognizes GOTO statements" do
      tokens = [
        Token.new("GOTO", :reserved, []),
        Token.new("200", :integer, [])
      ]

      result = BasicCompiler.Parser.Goto.build_tokens(tokens)
      assert length(result) == 1
      assert hd(result).string == "GOTO200"
    end

    test "recognizes predefined functions" do
      tokens = [
        Token.new("SIN", :reserved, []),
        Token.new("COS", :reserved, []),
        Token.new("LET", :reserved, [])
      ]

      result = BasicCompiler.Parser.Predef.build_tokens(tokens)
      assert Enum.at(result, 0).type == :predef
      assert Enum.at(result, 1).type == :predef
      assert Enum.at(result, 2).type == :reserved
    end

    test "recognizes DATA statements" do
      tokens = [
        Token.new("DATA", :reserved, []),
        Token.new("1", :integer, []),
        Token.new(",", :special, []),
        Token.new("2", :integer, [])
      ]

      result = BasicCompiler.Parser.Data.build_tokens(tokens)
      assert Enum.any?(result, fn t -> t.type == :data end)
    end

    test "recognizes NEXT statements" do
      tokens = [
        Token.new("NEXT", :reserved, []),
        Token.new("I", :letter, [])
      ]

      result = BasicCompiler.Parser.Next.build_tokens(tokens)
      assert length(result) == 1
      assert hd(result).type == :next
    end
  end

  describe "number recognition" do
    test "recognizes integers" do
      content = "123"
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> t.string == "123" and t.type == :integer end)
    end

    test "recognizes floating point numbers" do
      content = "123.456"
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> t.string == "123.456" and t.type == :number end)
    end

    test "recognizes scientific notation" do
      content = "1.2E10"
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> String.contains?(t.string, "E") and t.type == :number end)
    end

    test "recognizes signed numbers" do
      content = "LET X = -5"
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> t.string == "-5" and t.type == :signed_number end)
    end
  end

  describe "string handling" do
    test "recognizes string literals" do
      content = "\"HELLO\""
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> t.string == "\"HELLO\"" and t.type == :string end)
    end

    test "recognizes REM statements" do
      content = "REM This is a comment\n"
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> t.type == :rem end)
    end
  end

  describe "reserved keywords" do
    test "recognizes all BASIC keywords" do
      keywords = ~w[PRINT LET IF THEN FOR TO STEP NEXT GOSUB GOTO RETURN END DIM DATA READ]

      Enum.each(keywords, fn keyword ->
        tokens = compile_string(keyword)
        assert Enum.any?(tokens, fn t -> t.string == keyword and t.type == :reserved end),
               "Failed to recognize keyword: #{keyword}"
      end)
    end
  end

  describe "identifiers" do
    test "recognizes single letter identifiers" do
      content = "X"
      tokens = compile_string(content)
      # Single letter should remain as letter token (not promoted to identifier unless followed by digit)
      assert Enum.any?(tokens, fn t -> t.string == "X" and t.type == :letter end)
    end

    test "recognizes letter-digit identifiers" do
      content = "X1"
      tokens = compile_string(content)
      assert Enum.any?(tokens, fn t -> t.string == "X1" and t.type == :identifier end)
    end
  end

  # Helper function to compile a string directly
  defp compile_string(content) do
    # Ensure content ends with newline
    content = if String.ends_with?(content, "\n"), do: content, else: content <> "\n"

    content
    |> BasicCompiler.Lexer.LineParser.parse_lines()
    |> BasicCompiler.Lexer.CharParser.parse_char_all_lines()
    |> BasicCompiler.Lexer.AsciiCategorizer.classify_char_all_lines()
    |> BasicCompiler.Lexer.execute_lexer()
    |> BasicCompiler.Parser.execute_parser()
  end
end
