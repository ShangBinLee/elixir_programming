defmodule Macros.Myunless do
  @doc """
  # 練習問題：MacrosAndCodeEvaluation-1

  標準のunlessの機能をもつmyunlessという名前のマクロを書こう。\s\s
  その中で標準のif式を使ってもよい。

  """
  defmacro myunless(condition, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    quote do
      if !unquote(condition) do
        unquote(do_clause)
      else
        unquote(else_clause)
      end
    end
  end
end

defmodule Macros.Myunless.Test do
  require Macros.Myunless
  alias Macros.Myunless

  Myunless.myunless [] === {} do
    IO.puts "false"
  else
    IO.puts "true"
  end
end
