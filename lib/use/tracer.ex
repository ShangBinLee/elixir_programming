defmodule Use.Tracer do
  import IO.ANSI

  def dump_args(args) do
    args |> Enum.map(&inspect/1) |> Enum.join(", ")
  end

  def dump_defn(name, args) do
    "#{name}(#{dump_args(args)})"
  end

  @doc """
  # 練習問題：LinkingModules-BehavioursAndUse-2

  組込み関数の`IO.ANSI`はANSIエスケープシーケンスを表現する関数を定義する。\s\s
  これを使って、（例えば）文字列をターミナルに出力する際に、色や太字、反転、アンダーライン\s\s
  といった効果をつけることができる（ターミナルがサポートしていれば。）\s\s

        iex> import IO.ANSI
        iex> IO.puts ["Hello", white(), green_background(), "world!"]
        Hello, World!

  モジュールを調査し、それを使って、トレースの出力を色付けしてみよう。\s\s
  文字列のリストを`IO.puts`に渡すと、なぜ動くのだろうか。

  """
  defmacro def(definition = {name, _, args}, do: content) do
    quote do
      Kernel.def(unquote(definition)) do
        # unquote(args)はdefで定義した関数のパラメータ名のリストにパースされる
        # つまり、マクロ関数に渡された時は内部表現であったものがunquoteでパラメータのリストになる。
        # それで、関数の呼び出し時に渡される引数をパラメータ名で参照できるようになる。
        IO.puts [blue(), "===> call: #{dump_defn(unquote(name), unquote(args))}", default_color()]
        result = unquote(content)
        IO.puts [blue(), "===> result: #{result}", default_color()]
        result
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [def: 2]
      import unquote(__MODULE__), only: [def: 2, dump_defn: 2]
    end
  end
end

defmodule Use.Tracer.Test do
  use Use.Tracer

  def puts_sum_three(a, b, c), do: IO.inspect(a + b + c)
  def add_list(list), do: Enum.reduce(list, 0, &(&1 + &2))
  # def add(a, b) when is_number(a) and is_number(b) do
    # a + b
  # end
end

Use.Tracer.Test.puts_sum_three(1, 2, 3)
Use.Tracer.Test.add_list([5, 6, 7, 8])
# Use.Tracer.Test.add(1, 2)
