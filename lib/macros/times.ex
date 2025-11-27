defmodule Macros.Times do
  @doc """
  # 練習問題：MacrosAndCodeEvaluation-2

  数値を一つ引数として取る、times_nというマクロを定義しよう。\s\s
  このマクロは、times_nという名前の関数を、呼び出したモジュールの中に定義する。\s\s
  定義された関数は、一つの引数をとり、それにnを掛けた値を返す。\s\s
  つまり、times_n(3)はtimes_3という関数を定義し、times_3(4)は12を返す。\s\s

  """
  defmacro times_n(n) do
    func_name = :"times_#{n}"

    quote do
      def unquote(func_name)(x) do
        x * unquote(n)
      end
    end
  end
end

defmodule Macros.Times.Test do
  require Macros.Times
  alias Macros.Times

  Times.times_n(3)
  Times.times_n(4)
end

IO.puts Macros.Times.Test.times_3(4)
IO.puts Macros.Times.Test.times_4(5)
