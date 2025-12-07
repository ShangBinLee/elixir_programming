defmodule Use.Tracer do
  import IO.ANSI

  def dump_args(args) do
    args |> Enum.map(&inspect/1) |> Enum.join(", ")
  end

  def dump_defn(name, args) do
    "#{name}(#{dump_args(args)})"
  end

  @doc """
  マクロ内で呼び出されると、内部表現を引数として受け取って\s\s
  関数の中身にログ出力処理を追加したものをquoteして返す。

  ## パラメータ

    - name：関数名
    - args：関数のパラメータ定義
      - unquote(args)は内部表現を関数のパラメータ名のリストにパースする
    - content：元々defに渡されたdo..endの部分、関数の中身

  """
  def quote_do(name, args, content) do
    quote do
      IO.puts [blue(), "===> call: #{dump_defn(unquote(name), unquote(args))}", default_color()]
      result = unquote(content)
      IO.puts [blue(), "===> result: #{result}", default_color()]
      result
    end
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

  # 練習問題：LinkingModules-BehavioursAndUse-3

  （難問）ガード節のある関数定義をTestモジュールに加えてみよう。\s\s
  トレースがうまくいかないことがわかるだろう。\s\s
  ・うまくいかない理由を見つけよう。\s\s
  ・修正方法があるか考えよう。

  """
  defmacro def(
    {:when, _, _args = [definition = {name, _, args}, guard]},
    do: content
  ) do
    # ガード節対応
    quote do
      Kernel.def(unquote(definition) when unquote(guard)) do
        unquote(quote_do(name, args, content))
      end
    end
  end

  defmacro def(definition = {name, _, args}, do: content) do
    # それ以外の全ケース
    quote do
      Kernel.def(unquote(definition)) do
        unquote(quote_do(name, args, content))
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
  def add(a, b) when is_number(a) and is_number(b) do
    a + b
  end

  def any_of(a, b) when is_number(a) or is_number(b) do
    if is_number(a) do
      a
    else
      b
    end
  end

  def range(start, final) when is_integer(start) and start > -1 and is_integer(final) and final >= start do
    start..final
  end
end

Use.Tracer.Test.puts_sum_three(1, 2, 3)
Use.Tracer.Test.add_list([5, 6, 7, 8])
Use.Tracer.Test.add(1, 4)
Use.Tracer.Test.any_of(1, [65])
Use.Tracer.Test.range(1, 2)
