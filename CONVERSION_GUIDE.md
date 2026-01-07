# Ruby to Elixir Conversion Guide

This document details the conversion process from the Ruby BASIC compiler to the Elixir implementation.

## Overview

The conversion maintains 100% functional parity with the Ruby version while adopting Elixir idioms and patterns. The architecture, abstraction levels, and pipeline structure remain identical.

## Key Conversion Patterns

### 1. State Machines (AASM → State Passing)

**Ruby (AASM):**
```ruby
class IntegerRecognizer
  include AASM
  
  aasm do
    state :idle, initial: true
    state :recognizing
    
    event :recognize do
      transitions from: [:idle, :recognizing], to: :recognizing
    end
  end
  
  def build_tokens
    @tokens.each do |token|
      if token.type == :digit
        self.recognize
        # ...
      end
    end
  end
end
```

**Elixir (State Passing):**
```elixir
defmodule BasicCompiler.Lexer.Integer do
  def build_tokens(tokens) do
    do_build_tokens(tokens, [], [], :idle)
  end
  
  defp do_build_tokens([], result_tokens, token_stack, :recognizing) do
    # Build final token
  end
  
  defp do_build_tokens([token | rest], result_tokens, token_stack, state) do
    case {token.type, state} do
      {:digit, _} ->
        do_build_tokens(rest, result_tokens, [token | token_stack], :recognizing)
      # ...
    end
  end
end
```

### 2. Data Structures

**Ruby:**
```ruby
require 'linked-list'

tokenized_lines = LinkedList::List.new
tokenized_lines.push(token)
```

**Elixir:**
```elixir
# Lists are built in reverse and then reversed at the end
result_tokens = [token | result_tokens]
# Later:
Enum.reverse(result_tokens)
```

### 3. Classes → Modules + Structs

**Ruby:**
```ruby
class Token
  attr_accessor :string, :type, :child_tokens
  
  def initialize(string, type, child_tokens)
    @string = string
    @type = type
    @child_tokens = child_tokens
  end
end
```

**Elixir:**
```elixir
defmodule BasicCompiler.Helpers.Token do
  defstruct [:string, :type, :child_tokens]
  
  def new(string, type, child_tokens \\ []) do
    %__MODULE__{
      string: string,
      type: type,
      child_tokens: child_tokens
    }
  end
end
```

### 4. Iteration Patterns

**Ruby:**
```ruby
@tokens.each do |token|
  process(token)
end
```

**Elixir:**
```elixir
# For transformation:
Enum.map(tokens, &process/1)

# For filtering:
Enum.filter(tokens, &predicate/1)

# For accumulation (like our parsers):
Enum.reduce(tokens, acc, fn token, acc ->
  # process
end)

# Or recursive pattern matching:
defp process([token | rest], acc) do
  process(rest, [transform(token) | acc])
end
```

### 5. Error Handling

**Ruby:**
```ruby
class ParserError < StandardError
end

raise ParserError.new, "error message"
```

**Elixir:**
```elixir
defmodule BasicCompiler.Helpers.ParserError do
  defexception message: "Parser error occurred"
end

raise ParserError, message: "error message"
```

## File-by-File Conversion

### Helpers

| Ruby | Elixir | Notes |
|------|--------|-------|
| `lib/helpers/token.rb` | `lib/helpers/token.ex` | Class → Struct with `new/3` constructor |
| `lib/helpers/classified_char.rb` | `lib/helpers/classified_char.ex` | Class → Struct with `new/3` constructor |
| `lib/helpers/parser_error.rb` | `lib/helpers/parser_error.ex` | StandardError → defexception |
| `lib/helpers/lexer_automatas.rb` | `lib/helpers/lexer_automatas.ex` | Module constants → Module functions |

### Lexer Components

| Ruby | Elixir | Key Changes |
|------|--------|-------------|
| `lib/lexer/file_reader.rb` | `lib/lexer/file_reader.ex` | AASM removed, direct File.read/1 |
| `lib/lexer/line_parser.rb` | `lib/lexer/line_parser.ex` | LinkedList → Elixir list |
| `lib/lexer/char_parser.rb` | `lib/lexer/char_parser.ex` | String.split → String.graphemes |
| `lib/lexer/ascii_categorizer.rb` | `lib/lexer/ascii_categorizer.ex` | AASM → Enum.map with pattern matching |
| `lib/lexer/string_builder.rb` | `lib/lexer/string_builder.ex` | AASM → recursive state passing |
| `lib/lexer/rem_builder.rb` | `lib/lexer/rem_builder.ex` | AASM → pattern matching on string chars |
| `lib/lexer/clear_delimiter.rb` | `lib/lexer/clear_delimiter.ex` | Simplified to Enum.filter |
| `lib/lexer/reserved_keywords.rb` | `lib/lexer/reserved_keywords.ex` | Word list as function, recursive matching |
| `lib/lexer/identifier.rb` | `lib/lexer/identifier.ex` | AASM → state passing |
| `lib/lexer/integer.rb` | `lib/lexer/integer.ex` | AASM → state passing |
| `lib/lexer/number_recognizer.rb` | `lib/lexer/number_recognizer.ex` | Complex state machine → pattern matching |
| `lib/lexer/signal_number_recognizer.rb` | `lib/lexer/signal_number_recognizer.ex` | AASM → state passing |

### Parser Components

| Ruby | Elixir | Key Changes |
|------|--------|-------------|
| `lib/parser/gosub.rb` | `lib/parser/gosub.ex` | AASM → state passing |
| `lib/parser/goto.rb` | `lib/parser/goto.ex` | AASM → state passing |
| `lib/parser/predef.rb` | `lib/parser/predef.ex` | Simplified to Enum.map |
| `lib/parser/data.rb` | `lib/parser/data.ex` | Complex AASM → pattern matching |
| `lib/parser/next.rb` | `lib/parser/next.ex` | AASM → state passing |
| `lib/parser/dim_component.rb` | `lib/parser/dim_component.ex` | AASM → state passing |
| `lib/parser/dim.rb` | `lib/parser/dim.ex` | AASM → state passing |

### Main Entry Points

| Ruby | Elixir | Key Changes |
|------|--------|-------------|
| `main.rb` | `lib/basic_compiler.ex` | Added escript main/1, pipe operator |
| `lexer.rb` | `lib/lexer.ex` | Pipeline with pipe operator |
| `parser.rb` | `lib/parser.ex` | Pipeline with pipe operator |

## Design Decisions

### 1. State Management

Instead of AASM's object-oriented state machines, we use:
- **Pattern matching** on state atoms (`:idle`, `:recognized`, etc.)
- **Tail-recursive functions** with state as a parameter
- **Accumulator pattern** for building results

### 2. List Processing

Ruby's linked-list gem operations map to Elixir's built-in list operations:
- `list.push(item)` → `[item | list]` (prepend)
- Iterate in reverse, then call `Enum.reverse/1` at the end
- More efficient than appending to the end

### 3. No Dependencies

The Elixir version uses only the standard library:
- No external state machine libraries needed
- No linked-list library needed
- Simpler dependency management

### 4. Immutability

All data structures are immutable:
- Tokens are never modified in place
- State transitions create new data structures
- Easier to reason about and test

### 5. Pattern Matching

Extensive use of pattern matching:
- Function heads for different cases
- Case expressions for multi-way branching
- Guards for additional constraints

## Testing Strategy

The test suite covers:

1. **Unit Tests**: Individual stage functionality
2. **Integration Tests**: Full pipeline with example files
3. **Edge Cases**: Empty inputs, single characters, complex numbers
4. **Token Types**: All token types are verified

## Performance Considerations

While performance wasn't the primary goal, the Elixir version benefits from:
- Tail-call optimization for recursive functions
- Efficient list operations
- BEAM VM's lightweight processes (not utilized yet, but available)

## Future Enhancements

Potential improvements while maintaining compatibility:

1. **Parallel Processing**: Process multiple files concurrently
2. **Streaming**: Process large files without loading entirely into memory
3. **Type Specs**: Add @spec annotations for all public functions
4. **Dialyzer**: Add static type analysis
5. **Property Testing**: Use StreamData for property-based tests
6. **Documentation**: Generate ExDoc HTML documentation

## Building and Running

### Development
```bash
cd basic_compiler
mix compile
mix test
mix run -e 'BasicCompiler.compile_and_print("examples/reference.bas")'
```

### Production
```bash
cd basic_compiler
MIX_ENV=prod mix escript.build
./basic_compiler examples/bubblesort.bas
```

## Verification

To verify the conversion maintains parity:

1. Run both versions on the same input
2. Compare token output structure
3. Verify all token types are recognized
4. Check error handling behavior

```bash
# Ruby version
ruby main.rb examples/reference.bas > ruby_output.txt

# Elixir version  
cd basic_compiler
./basic_compiler examples/reference.bas > elixir_output.txt

# Compare (structure should be equivalent, format may differ)
diff ruby_output.txt elixir_output.txt
```

## Common Pitfalls

### 1. List Reversal
Remember to reverse lists built with prepending:
```elixir
# Build in reverse for efficiency
result = Enum.reduce(items, [], fn item, acc -> [process(item) | acc] end)
# Reverse at the end
Enum.reverse(result)
```

### 2. Pattern Matching Order
First match wins, so order matters:
```elixir
# More specific patterns first
case value do
  {:ok, :special_case} -> handle_special()
  {:ok, _} -> handle_general()
  {:error, reason} -> handle_error(reason)
end
```

### 3. Variable Scope
Variables are immutable and scoped to their block:
```elixir
# This creates a NEW variable, doesn't modify the old one
result_tokens = [token | result_tokens]
```

## Conclusion

The Elixir conversion successfully maintains all functionality while adopting idiomatic patterns. The code is more concise, leverages Elixir's strengths, and remains maintainable and testable.
