ExUnit.start()

defmodule Macros.ExplainTest do
  require Macros.Explain
  alias Macros.Explain
  use ExUnit.Case

  def assert_equal(explain_result, expected) do
    expr_eval_result = explain_result
    |> String.split("\n")
    |> Enum.drop(-2)
    |> Enum.join("\n")
    |> Code.eval_string()
    |> elem(0)

    assert expr_eval_result === expected
  end

  test "足し引き算" do
    Explain.explain(do: 1 + 2 - 3)
    |> assert_equal(0)
  end

  test "掛け割り算" do
    Explain.explain(do: 2 * 10 / 4)
    |> assert_equal(5.0)
  end

  test "四則演算" do
    Explain.explain(do: 1 * 3 + 3 - 5 / 12 * 1.5)
    |> assert_equal(5.375)
  end

  test "括弧含み" do
    Explain.explain(do: (2 + 3 * 4) * (5 - 2) / (4 + 3 * 1 / 2))
    |> assert_equal(7.636363636363637)
  end

  test "少数含み" do
    Explain.explain(do: (3.242 + 1.2) * 3.2 / (4.5 + 3) * (4 + 2))
    |> assert_equal(11.37152)
  end
end
