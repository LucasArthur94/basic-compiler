# Quick Start Guide

## For Elixir Version (Recommended)

### Prerequisites
- Elixir 1.14+ and Erlang/OTP 25+ installed

### Run in 3 Steps

```bash
# 1. Navigate to the Elixir project
cd basic_compiler

# 2. Build the executable (first time only)
mix escript.build

# 3. Run on any BASIC file
./basic_compiler examples/reference.bas
```

### Alternative: Using Mix Directly

```bash
cd basic_compiler
mix run -e 'BasicCompiler.compile_and_print("examples/reference.bas")'
```

### Run Tests

```bash
cd basic_compiler
mix test
```

## For Ruby Version (Legacy)

### Prerequisites
- Ruby 2.x or 3.x installed

### Run in 3 Steps

```bash
# 1. Install dependencies (first time only)
bundle install

# 2. Run on any BASIC file
ruby main.rb examples/reference.bas
```

## Example Files

Try these BASIC programs in the `examples/` directory:

| File | Description |
|------|-------------|
| `reference.bas` | Simple "Hello World" |
| `exponential.bas` | Scientific notation demo |
| `selectionsort.bas` | Selection sort algorithm |
| `bubblesort.bas` | Bubble sort algorithm |

## Expected Output

When you run the compiler, you'll see tokens printed like:

```
=============
%BasicCompiler.Helpers.Token{
  string: "10",
  type: :integer,
  child_tokens: [...]
}
=============
%BasicCompiler.Helpers.Token{
  string: "PRINT",
  type: :reserved,
  child_tokens: [...]
}
...
```

## Common Issues

### "mix: command not found"
Install Elixir: https://elixir-lang.org/install.html

### "ruby: command not found"  
Install Ruby: https://www.ruby-lang.org/en/downloads/

### Permission denied on escript
```bash
chmod +x basic_compiler/basic_compiler
```

## Next Steps

- Read the full [README.md](README.md) for architecture details
- Check [basic_compiler/README.md](basic_compiler/README.md) for API documentation
- Review [CONVERSION_GUIDE.md](CONVERSION_GUIDE.md) for implementation details
- See [MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md) for project status

## Quick Commands Reference

### Elixir
```bash
cd basic_compiler

# Compile
mix compile

# Test
mix test

# Build executable
mix escript.build

# Run
./basic_compiler <file.bas>

# Format code
mix format

# Interactive shell
iex -S mix
```

### Ruby
```bash
# Install deps
bundle install

# Run
ruby main.rb <file.bas>
```

## Getting Help

1. **Full Documentation**: Read README.md files
2. **Examples**: Check the `examples/` directory
3. **Tests**: See `basic_compiler/test/` for usage examples
4. **Inline Docs**: All modules have @moduledoc and @doc annotations
