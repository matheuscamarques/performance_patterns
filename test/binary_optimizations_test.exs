defmodule PerformancePatterns.BinaryOptimizationsTest do
  use ExUnit.Case
  doctest PerformancePatterns.BinaryOptimizations

  import PerformancePatterns, only: [generate_test_binary: 1]

  test "naive and optimized binary processing yields the same result" do
    # Generate a binary with 100 16-bit unsigned little-endian integers
    binary = generate_test_binary(100)

    # The naive version should correctly decode the binary
    expected_result = PerformancePatterns.BinaryOptimizations.process_stream_naive(binary)

    # The optimized version should produce the exact same list of integers
    optimized_result = PerformancePatterns.BinaryOptimizations.process_stream_optimized(binary)

    assert optimized_result == expected_result
    # Also check if we got the correct number of items
    assert length(optimized_result) == 100
  end

  test "processing an empty binary results in an empty list" do
    binary = <<>>
    assert PerformancePatterns.BinaryOptimizations.process_stream_naive(binary) == []
    assert PerformancePatterns.BinaryOptimizations.process_stream_optimized(binary) == []
  end
end
