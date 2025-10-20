defmodule StringsBinaries do
  @moduledoc """
  シングルクオート文字列、ダブルクオート文字列、バイナリ関連のモジュール
  """

  defmodule CharLists do
    @moduledoc """
    シングルクオート文字列のモジュール
    """

    @doc """
    # 練習問題：StringsAndBinaries-2

    2つのシングルクオート文字列がアナグラムであるかを判別する。

    ## 例

        iex> StringsBinaries.CharLists.anagram?(~c'かたい', ~c'たかい')
        true
        iex> StringsBinaries.CharLists.anagram?(~c'あらす', ~c'あすら')
        true
        iex> StringsBinaries.CharLists.anagram?(~c'するどい', ~c'すてきな')
        false
        iex> StringsBinaries.CharLists.anagram?(~c'おはよう', ~c'こんにちは')
        false
        iex> StringsBinaries.CharLists.anagram?("めしあげ", "しめあげ")
        ** (ArgumentError) argument error

    """
    @spec anagram?(charlist(), charlist()) :: boolean()
    def anagram?(word1, word2), do: _empty?(word1 -- word2) and _empty?(word2 -- word1)
    defp _empty?([]), do: true
    defp _empty?(_), do: false

    @doc """
    # 練習問題：StringsAndBinaries-4

    （難問）「数字 [+-*/] 数字」という形のシングルクオート文字列を受け、その計算結果を返す

    ## 要素の種類

      - 数字：積み重ねる物（他の要素により、解消される）
      - 空白文字：解消要素（積み重なってる物、`:space`、テイルを返す）
      - 演算子：解消要素（積み重なってる物、`op`、テイルを返す）
      - 文字列が終わった場合：解消要素、終了条件（積み重なってる物だけを返す）

    ## 組み合わせパターン

      - 積み重なってる物 + 解消要素 = `number + (:space or op)`
      - 解消要素だけ = `:empty + (:space or op)`

    ## パラメータ

      - expression：`~r{^\\d+\\s[\\+\\-\\*/]\\s\\d+$}`に一致するシングルクオート文字列

    ## 例

        iex> StringsBinaries.CharLists.calculate(~c'2 + 5')
        7
        iex> StringsBinaries.CharLists.calculate(~c'123 + 27')
        150
        iex> StringsBinaries.CharLists.calculate(~c'100 - 150')
        -50
        iex> StringsBinaries.CharLists.calculate(~c'200 * 12')
        2400
        iex> StringsBinaries.CharLists.calculate(~c'100 / 22')
        4.545454545454546

        iex> StringsBinaries.CharLists.calculate(~c'5')
        ** (FunctionClauseError) no function clause matching in StringsBinaries.CharLists._calculate/1

        iex> StringsBinaries.CharLists.calculate(~c'5 * 5+5')
        ** (FunctionClauseError) no function clause matching in StringsBinaries.CharLists._calculate/1

        iex> StringsBinaries.CharLists.calculate(~c'55 5')
        ** (FunctionClauseError) no function clause matching in StringsBinaries.CharLists._calculate/1

        iex> StringsBinaries.CharLists.calculate(~c' + 5')
        ** (RuntimeError) 左辺に数字を入力してください

        iex> StringsBinaries.CharLists.calculate(~c'2   5')
        ** (RuntimeError) 演算子を入力してください

        iex> StringsBinaries.CharLists.calculate(~c'2 * ')
        ** (RuntimeError) 右辺に数字を入力してください

    """
    @spec calculate(charlist()) :: integer()
    def calculate(expression) do
      _parse(expression, :empty)
      |> _calculate()
    end

    defp _calculate([:empty, :space, :empty, _, :empty, :space, _]), do: raise "左辺に数字を入力してください"
    defp _calculate([_, :space, :empty, :space, :empty, :space, _]), do: raise "演算子を入力してください"
    defp _calculate([_, :space, :empty, _, :empty, :space, :empty]), do: raise "右辺に数字を入力してください"

    @funcs_map %{?+ => &+/2, ?- => &-/2, ?* => &*/2, ?/ => &//2}
    defp _calculate([left_number, :space, :empty, op, :empty, :space, right_number])
    do
      @funcs_map[op].(left_number, right_number)
    end

    @num_ch ~c'0123456789'
    defp _parse([ch | tail], :empty) # 積み重ね始める
    when ch in @num_ch
    do
      _parse(tail, ch - ?0)
    end
    defp _parse([ch | tail], number) # 積み重ね続ける
    when ch in @num_ch
    do
      _parse(tail, number * 10 + ch - ?0)
    end
    defp _parse([?\s | tail], value) # 解消
    do
      [value | [:space | _parse(tail, :empty)]]
    end
    @op_ch ~c'+-*/'
    defp _parse([ch | tail], value) # 解消
    when ch in @op_ch
    do
      [value | [ch | _parse(tail, :empty)]]
    end
    defp _parse([], value), do: [value | []] # 解消、終了
  end
end
