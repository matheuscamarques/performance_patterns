# lib/performance_patterns/string_refactoring.ex
defmodule PerformancePatterns.StringRefactoring do
  @moduledoc """
  Demonstrates replacing generic list/string operations with bespoke,
  recursive functions for significant performance gains in hot code paths.
  This mirrors the "String Manipulation" section of the source paper.
  """

  @doc """
  Naive date formatting using a generic, multi-step approach involving
  `Enum.map` and `List.flatten`. This simulates the use of a general-purpose
  formatting library which often relies on `lists:flatten/1`, a known
  performance bottleneck for deep or long lists of lists.
  """
  def format_date_naive({y, m, d}) do
    ["YY", "/", "MM", "/", "DD"]
    |> Enum.map(fn
      "YY" -> Integer.to_string(rem(y, 100))
      "MM" -> Integer.to_string(m)
      "DD" -> Integer.to_string(d)
      sep -> sep
    end)
    |> List.flatten()
    |> IO.iodata_to_binary()
  end

  @doc """
  Optimized date formatting using a bespoke function that builds an iolist
  directly. This avoids the creation of intermediate list structures and the
  costly `List.flatten/1` operation.
  """
  def format_date_optimized({y, m, d}) do
    [
      format_year_yy(rem(y, 100)),
      "/",
      format_two_digits(m),
      "/",
      format_two_digits(d)
    ]
    |> IO.iodata_to_binary()
  end

  # Private helper functions for the optimized version leverage pattern matching
  # for conditional logic, which is highly efficient.
  defp format_year_yy(y) when y < 10, do: ["0", Integer.to_string(y)]
  defp format_year_yy(y), do: Integer.to_string(y)

  defp format_two_digits(n) when n < 10, do: ["0", Integer.to_string(n)]
  defp format_two_digits(n), do: Integer.to_string(n)
end
