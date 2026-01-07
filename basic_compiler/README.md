# BasicCompiler

An Elixir-based BASIC compiler implementing a complete lexical analysis and parsing pipeline for the BASIC programming language.

## Description

This is a complete Elixir conversion of a Ruby-based BASIC compiler, maintaining 100% functional parity while using idiomatic Elixir patterns. The compiler processes BASIC source files through a multi-stage pipeline to generate structured token representations.

## Features

- **Complete Lexical Analysis**: Recognizes strings, comments (REM), reserved keywords, identifiers, integers, floating-point numbers, and signed numbers
- **Advanced Number Recognition**: Supports scientific notation (e.g., 1.2E10, -2.0E-5)
- **Parser Stage**: Recognizes high-level BASIC constructs (GOSUB, GOTO, DATA, NEXT, DIM)
- **Functional Pipeline**: Uses Elixir's pipe operator for clean data transformation
- **No External Dependencies**: Pure Elixir implementation using only the standard library
- **Executable CLI**: Can be built as a standalone escript

## Installation

Ensure you have Elixir 1.14+ and Erlang/OTP 25+ installed.

```bash
# Clone or navigate to the project
cd basic_compiler

# Get dependencies (none currently, but good practice)
mix deps.get

# Compile the project
mix compile

# Build the executable
mix escript.build
```

## Usage

### Using Mix directly

```bash
# Compile and run on a BASIC file
mix run -e 'BasicCompiler.compile_and_print("examples/reference.bas")'

# Or use the module functions
iex -S mix
iex> BasicCompiler.compile("examples/reference.bas")
```

### Using the escript executable

```bash
# Build the executable first
mix escript.build

# Run it
./basic_compiler examples/reference.bas
./basic_compiler examples/exponential.bas
./basic_compiler examples/selectionsort.bas
```

## Testing

The project includes a comprehensive test suite covering:
- Individual lexer stages
- Parser recognizers
- Number recognition (integers, floats, scientific notation, signed numbers)
- String and comment handling
- Reserved keyword recognition
- Identifier recognition
- Full integration tests with example files

```bash
# Run all tests
mix test

# Run with detailed output
mix test --trace

# Run specific test file
mix test test/basic_compiler_test.exs
```

## Architecture

The compiler is organized into a staged pipeline with clear separation of concerns:

### Lexer Pipeline (`lib/lexer/`)

1. **FileReader** - Reads BASIC source files from disk
2. **LineParser** - Splits content into lines
3. **CharParser** - Splits lines into individual characters
4. **AsciiCategorizer** - Classifies characters (letter, digit, special, delimiter)
5. **StringBuilder** - Recognizes string literals
6. **RemBuilder** - Recognizes REM comments
7. **ClearDelimiter** - Removes whitespace (keeps newlines)
8. **ReservedKeywords** - Identifies BASIC keywords
9. **Identifier** - Recognizes variable identifiers (letter + optional digit)
10. **Integer** - Recognizes integer sequences
11. **NumberRecognizer** - Recognizes floating-point and scientific notation
12. **SignalNumberRecognizer** - Recognizes signed numbers

### Parser Pipeline (`lib/parser/`)

1. **Gosub** - Recognizes GOSUB statements
2. **Goto** - Recognizes GOTO statements
3. **Predef** - Identifies predefined math functions (SIN, COS, TAN, etc.)
4. **Data** - Recognizes DATA statements with value lists
5. **Next** - Recognizes NEXT loop statements
6. **DimComponent** - Recognizes array dimension components
7. **Dim** - Recognizes DIM array declarations

### Helper Modules (`lib/helpers/`)

- **Token** - Token struct with string, type, and child_tokens
- **ClassifiedChar** - Character classification struct
- **ParserError** - Custom exception for parsing errors
- **LexerAutomatas** - Regular expressions and keyword definitions

## Module Structure

```
BasicCompiler                    # Main entry point
├── Lexer                        # Lexer orchestrator
│   ├── FileReader
│   ├── LineParser
│   ├── CharParser
│   ├── AsciiCategorizer
│   ├── StringBuilder
│   ├── RemBuilder
│   ├── ClearDelimiter
│   ├── ReservedKeywords
│   ├── Identifier
│   ├── Integer
│   ├── NumberRecognizer
│   └── SignalNumberRecognizer
├── Parser                       # Parser orchestrator
│   ├── Gosub
│   ├── Goto
│   ├── Predef
│   ├── Data
│   ├── Next
│   ├── DimComponent
│   └── Dim
└── Helpers
    ├── Token
    ├── ClassifiedChar
    ├── ParserError
    └── LexerAutomatas
```

## Examples

The `examples/` directory contains sample BASIC programs:

### reference.bas
```basic
10 PRINT "HELLO WORLD"
20 END
```

### exponential.bas
```basic
10 LET Z = -2.0E-5
```

### selectionsort.bas
```basic
20 DIM Z(4)
30 DATA 2, 7, 3, 1
40 READ Z(0), Z(1), Z(2), Z(3)
50 FOR I = 0 TO 3
...
```

## Token Output

The compiler generates structured tokens with the following format:

```elixir
%BasicCompiler.Helpers.Token{
  string: "PRINT",              # The token's string representation
  type: :reserved,              # Token type (atom)
  child_tokens: [...]           # Child tokens (for composite tokens)
}
```

Token types include:
- `:reserved` - BASIC keywords
- `:string` - String literals
- `:integer` - Integer numbers
- `:number` - Floating-point numbers
- `:signed_number` - Signed numbers
- `:identifier` - Variable identifiers
- `:letter` - Single letters
- `:digit` - Single digits
- `:special` - Special characters
- `:delimiter` - Whitespace/newlines
- `:rem` - Comments
- `:predef` - Predefined functions
- `:gosub`, `:goto`, `:data`, `:next`, `:dim`, `:dim_component` - BASIC constructs

## Development

### Code Style

The project follows standard Elixir conventions:
- Pattern matching for control flow
- Pipe operator for data transformations
- Immutable data structures
- Recursive functions with accumulator pattern
- Module-based organization

### Formatting

```bash
# Format all code
mix format
```

### Type Checking (Optional)

While not currently using Dialyzer, the codebase includes @type specs for key structs.

## Conversion from Ruby

This Elixir implementation maintains the same abstraction levels and pipeline structure as the original Ruby version while using Elixir idioms:

| Ruby | Elixir |
|------|--------|
| AASM state machines | State-passing with pattern matching |
| Linked lists | Native Elixir lists |
| Classes | Modules with structs |
| Instance variables | Function parameters and accumulators |
| `each` loops | `Enum.map`, `Enum.reduce` |
| `.push()` | `[item | list]` |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass with `mix test`
5. Format code with `mix format`
6. Submit a pull request

## License

MIT

## Acknowledgments

Converted from the original Ruby implementation while maintaining full functional parity and preserving the elegant staged pipeline architecture.
