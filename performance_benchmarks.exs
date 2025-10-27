alias PerformancePatterns.StringRefactoring
alias PerformancePatterns.BinaryOptimizations

IO.puts("--- Running String Refactoring Benchmarks ---")

# Input data for the string formatting functions
date_input = {2024, 5, 21}

Benchee.run(
  %{ 
    "format_date_naive" => fn -> StringRefactoring.format_date_naive(date_input) end,
    "format_date_optimized" => fn -> StringRefactoring.format_date_optimized(date_input) end
  },
  time: 5,
  warmup: 2,
  title: "String Formatting: Naive vs. Optimized (iolist)"
)

IO.puts("\n--- Running Deep List Flattening Benchmarks ---")

# Create a large, nested list to demonstrate the List.flatten bottleneck.
# This is a more representative benchmark for the string manipulation pattern.
deep_list_input = List.duplicate(List.duplicate(List.duplicate("hello", 10), 10), 100)

Benchee.run(
  %{
    "naive_flatten" => fn -> List.flatten(deep_list_input) |> IO.iodata_to_binary() end,
    "optimized_flatten (iolist)" => fn -> IO.iodata_to_binary(deep_list_input) end
  },
  time: 5,
  warmup: 2,
  title: "List Flattening: Naive (List.flatten) vs. Optimized (iolist)"
)

IO.puts("\n--- Running Binary Optimizations Benchmarks ---")

# Input data for the binary processing functions.
# We create a binary string containing 10,000 16-bit integers.
binary_input =
  for _ <- 1..10_000, into: <<>> do
    <<Enum.random(0..65535)::unsigned-little-integer-16>>
  end

Benchee.run(
  %{ 
    "process_stream_naive" => fn -> BinaryOptimizations.process_stream_naive(binary_input) end,
    "process_stream_optimized" => fn -> BinaryOptimizations.process_stream_optimized(binary_input) end
  },
  time: 5,
  warmup: 2,
  title: "Binary Processing: Naive (sub-binary) vs. Optimized (size)"
)