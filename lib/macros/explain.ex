defmodule Macros.Explain do
  @doc """
  # 練習問題：MacrosAndCodeEvaluation-3

  ElixirのテストフレームワークであるExUnitは、コードをquoteする賢いトリックを\s\s
  使っている。例えば、こうassertしたとき、

      assert 5 < 4

  以下のようなエラーを得るはずだ。

      Assertion with < failed
      code: 5 < 4
      lhs:  5
      rhs:  4

  このテストコードは左辺、演算子、右辺への代入パラメータにパースされる。\s\s
  https://github.com/elixir-lang/elixir/blob/v1.19.3/lib/ex_unit/lib/ex_unit/assertions.ex\s\s
  このファイルをしばらく読んでみよう。そして、どのようにこのトリックを実装しているか考えてみよう。\s\s
  （難問）それが終わったら、同じテクニックを使って、任意の算術式を受け取り、それを自然言語にして\s\s
  返す関数を実装できないか、考えてみよう。\s\s

      explain do: 2 + 3 * 4
      #=> multiply 3 and 4, then add 2

  # 四則演算の内部表現

  計算式は内部表現にすると計算順序が実際と逆のタプルになる。\s\s
  よって、実際の計算過程を示す文字列を作成するためには、そのタプルを下降しながら\s\s
  各再帰の段階で作り出す新しい文字列を結果文字列の冒頭に追加する必要がある。\s\s
  括弧はパースされて優先順位が適用された後なのでタプルには演算子とその対象しか入ってない。

  """
  defmacro explain([do: code]) do
    {result, _} = Code.eval_quoted(code)

    get_explanation(code, 1)
    <> "結果：#{result}\n"
  end

  def get_explanation(
    {op, _, [left, right]},
    var_num
  ) when is_number(left) and
    is_number(right)
    # もう掘り下げれないので終了
  do
    "数#{var_num} = #{left} #{op} #{right}\n"
  end

  def get_explanation(
    {op, _, [left, right]},
    var_num
  ) when is_number(left)
    # rightに対して再帰
  do
    get_explanation(right, var_num)
    <> "数#{var_num} = #{left} #{op} 数#{var_num}\n"
  end

  def get_explanation(
    {op, _, [left, right]},
    var_num
  ) when is_number(right)
    # leftに対して再帰
  do
    get_explanation(left, var_num)
    <> "数#{var_num} = 数#{var_num} #{op} #{right}\n"
  end

  def get_explanation(
    {op, _, [left, right]},
    var_num
  ) do
    get_explanation(left, var_num)
    <> get_explanation(right, var_num + 1)
    <> "数#{var_num} = 数#{var_num} #{op} 数#{var_num + 1}\n"
    # 両方とも再帰する場合はrightが別の名の変数になる。
  end
end
