# BASIC Compiler

This repository contains a BASIC compiler with implementations in both Ruby and Elixir.

## Ruby Version (Legacy)

The original Ruby implementation uses a staged pipeline with AASM state machines and linked lists.

### Files
- `main.rb` - Ruby entry point
- `lexer.rb` - Ruby lexer orchestrator
- `parser.rb` - Ruby parser orchestrator
- `lib/` - Ruby implementation modules

### Requirements
```bash
bundle install
```

### Usage
```bash
ruby main.rb examples/reference.bas
```

## Elixir Version (Current)

The Elixir implementation is a complete conversion maintaining 100% functional parity with the Ruby version, using idiomatic Elixir patterns including pattern matching, immutable data structures, and the pipe operator.

### Project Location
`basic_compiler/` - Elixir Mix project

### Requirements
- Elixir 1.14 or higher
- Erlang/OTP 25 or higher

### Installation & Build
```bash
cd basic_compiler
mix deps.get
mix compile
mix escript.build
```

### Usage

**Using Mix:**
```bash
cd basic_compiler
mix run -e 'BasicCompiler.compile_and_print("examples/reference.bas")'
```

**Using the compiled escript:**
```bash
cd basic_compiler
./basic_compiler examples/reference.bas
```

### Testing
```bash
cd basic_compiler
mix test
```

### Architecture

The compiler follows a staged pipeline architecture:

1. **Level 0** - File Reading (`FileReader`)
2. **Level 1** - Line Parsing (`LineParser`)
3. **Level 2** - Character Parsing (`CharParser`)
4. **Level 3-4** - Character Classification (`AsciiCategorizer`)
5. **Level 5-6** - Lexical Analysis (`Lexer`)
   - String Builder
   - REM Builder
   - Clear Delimiter
   - Reserved Keywords
   - Identifier Recognition
   - Integer Recognition
   - Number Recognition
   - Signed Number Recognition
6. **Level 7** - Parsing (`Parser`)
   - GOSUB Recognition
   - GOTO Recognition
   - Predefined Functions
   - DATA Statements
   - NEXT Statements
   - DIM Component Recognition
   - DIM Statement Recognition

### Examples

Sample BASIC programs are available in the `examples/` directory:
- `reference.bas` - Simple "Hello World" program
- `exponential.bas` - Scientific notation example
- `selectionsort.bas` - Selection sort algorithm
- `bubblesort.bas` - Bubble sort algorithm

## Conversion Notes

The Elixir version:
- Replaces AASM state machines with state-passing patterns
- Uses native Elixir lists instead of linked-list gem
- Converts Ruby classes to Elixir modules and structs
- Maintains the same abstraction levels and pipeline structure
- No external dependencies (Elixir standard library only)

## License

MIT
