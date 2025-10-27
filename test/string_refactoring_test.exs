defmodule PerformancePatterns.StringRefactoringTest do
  use ExUnit.Case
  doctest PerformancePatterns.StringRefactoring

  test "naive and optimized date formatting yields the same result for double-digit month/day" do
    date = {2024, 12, 25}
    expected = "24/12/25"

    assert PerformancePatterns.StringRefactoring.format_date_naive(date) == expected
    assert PerformancePatterns.StringRefactoring.format_date_optimized(date) == expected
  end

  test "naive and optimized date formatting yields the same result for single-digit month/day" do
    date = {2009, 1, 7}
    # The optimized version should pad with zeros, the naive one might not based on implementation.
    # Let's check the optimized one against the expected padded format.
    expected_optimized = "09/01/07"

    # We compare the naive output to the optimized output to ensure they are consistent.
    naive_result = PerformancePatterns.StringRefactoring.format_date_naive(date)
    optimized_result = PerformancePatterns.StringRefactoring.format_date_optimized(date)

    # The optimized function is the reference for correct padding
    assert optimized_result == expected_optimized
    # We now assert that the naive implementation matches the behaviour of the optimized one.
    assert naive_result == optimized_result
  end

  test "naive and optimized date formatting handles year 2000 correctly" do
    date = {2000, 10, 10}
    expected = "00/10/10"

    assert PerformancePatterns.StringRefactoring.format_date_naive(date) == expected
    assert PerformancePatterns.StringRefactoring.format_date_optimized(date) == expected
  end
end
