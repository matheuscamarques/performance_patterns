defmodule PerformancePatterns do
  @moduledoc """
  A library for the practical demonstration of performance patterns discussed in
  "Troubleshooting the Performance of a Large Erlang System" by Tsikoudis and Sugiyama.
  Each module contains pairs of functions: an idiomatic ("naive") implementation
  and a refactored ("optimized") implementation for comparison.
  """

  def generate_test_binary(size) do
    for _ <- 1..size, into: <<>> do
      <<Enum.random(0..65535)::unsigned-little-integer-16>>
    end
  end
end
