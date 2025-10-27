defmodule PerformancePatterns.BinaryOptimizations do
  @moduledoc """
  Demonstrates binary processing optimizations guided by the Erlang
  compiler's `+bin_opt_info` flag, as described in the paper.
  """

  @doc """
  Processes a binary stream using a naive recursive approach.

  The `decode_naive/1` helper function returns the remainder of the binary (`rest`),
  which forces the runtime to create a new sub-binary on every call. This triggers
  a `BINARY CREATED` warning from the compiler and leads to unnecessary memory
  allocation and GC pressure in a tight loop.
  """
  def decode_naive(<<value::unsigned-little-integer-16, rest::binary>>) do
    {value, rest}
  end

  def process_stream_naive(binary) do
    do_process_stream_naive(binary, [])
  end

  defp do_process_stream_naive(<<>>, acc), do: Enum.reverse(acc)

  defp do_process_stream_naive(binary, acc) do
    {value, rest} = decode_naive(binary)
    do_process_stream_naive(rest, [value | acc])
  end

  @doc """
  Processes a binary stream using an optimized recursive approach.

  This version uses binary pattern matching directly in the function head of the
  recursive helper. This allows the BEAM compiler to apply a crucial optimization:
  reusing the match context. Instead of creating new sub-binaries, it simply
  advances a pointer, avoiding allocations and GC pressure. The compiler confirms
  this with an `OPTIMIZED: match context reused` message when `+bin_opt_info` is enabled.
  """
  def process_stream_optimized(binary), do: do_process_stream_optimized(binary, [])

  defp do_process_stream_optimized(<<>>, acc), do: Enum.reverse(acc)

  defp do_process_stream_optimized(<<value::unsigned-little-integer-16, rest::binary>>, acc) do
    do_process_stream_optimized(rest, [value | acc])
  end
end
