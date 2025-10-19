defmodule ListsRecursion do
  @moduledoc """
  第7章「ListsAndRecursion」に載っている練習問題で興味深い問題の解答
  """

  @doc """
  # 練習問題：ListsAndRecursion-1

  リストの要素ごとに引数として与えられた関数を適用し、その結果の総和を求める。

  ## パラメータ

    - list：総和を求める要素のリスト
    - func：リストの要素ごとに適用する関数

  ## 例

      iex> ListsRecursion.mapsum([1, 2, 3], &(&1 * 5))
      30
      iex> ListsRecursion.mapsum([100, 200, 5], &(rem(&1, 7)))
      11
      iex> ListsRecursion.mapsum([10.2, 5.23, -1.2], &(&1 * -1))
      -14.23

  """
  @spec mapsum(list(number()), (number() -> number())) :: number()
  def mapsum(list, func), do: Enum.reduce(list, 0, &(func.(&1) + &2))

  @doc """
  # 練習問題：ListsAndRecursion-2

  リストの要素の最大値を求める。

  ## 例

      iex> ListsRecursion.max([2])
      2
      iex> ListsRecursion.max([2, 3, 11.23, 10, 11, 11.229])
      11.23
      iex> ListsRecursion.max(~c'ABCDEなでしこ')
      12394 # 「な」の文字コード

  """
  @spec max(nonempty_list(term())) :: term()
  def max([head | tail]), do: Enum.reduce(tail, head, &(get_max/2))

  @doc """

  2つの数値のうち、大きい方を返す。

  ## 例

      iex> ListsRecursion.get_max(1, 2)
      2
      iex> ListsRecursion.get_max(20.5, 20)
      20.5
      iex> ListsRecursion.get_max(<<23>>, <<64.5>>)
      <<64.5>>

  """
  def get_max(value_1, value_2) when value_1 >= value_2, do: value_1
  def get_max(_value_1, value_2), do: value_2

  @doc """
  # 練習問題：ListsAndRecursion-3

  シングルクオート文字列の各文字コードに`n`を足したシングルクオート文字列を返す。

  ただし、足した結果が`'z'`の文字コードを超えたら`'a'`に回り、`'a'`を下回ったら`'z'`に回る。

  ## パラメータ

    - charlist：シングルクオート文字列
    - n：各文字コードに足す整数

  ## 例

      iex> ListsRecursion.caesar(~c'ryvkve', 13)
      ~c'elixir'
      iex> ListsRecursion.caesar(~c'rei', 0)
      ~c'rei'
      iex> ListsRecursion.caesar(~c'opavrhnl', -7)
      ~c'hitokage'

  """
  @spec caesar(charlist(), integer()) :: charlist()
  def caesar(charlist, n), do: Enum.map(charlist, &(circle_if_possible(&1 + n)))

  @z_code 122
  @z_code_next (@z_code + 1)
  @a_code 97
  @a_code_prev (@a_code - 1)
  # z + 1 = a -> 大前提(overflow)
  # z + 1 = z_next -> 宣言
  # c = z_next + x (x >= 0) -> 式1
  # c = a + x -> 大前提、宣言により置き換え（式2）
  # c = a + (c - z_next) -> 式1により置き換え（式3）
  # c = a + (c - a) -> 大前提、宣言により置き換え
  # c = c
  # caesarで式1になった場合、式3とも表せる。
  defp circle_if_possible(c) when @z_code_next <= c, do: @a_code + (c - @z_code_next)
  # a - 1 = z -> 大前提(underflow)
  # a - 1 = a_prev -> 宣言
  # c = a_prev - x (x >= 0) -> 式1
  # c = z - x -> 大前提、宣言により置き換え（式2）
  # c = z - (a_prev - c) -> 式1により置き換え（式3）
  # c = z - (z - c) -> 大前提、宣言により置き換え
  # c = c
  # caesarで式1になった場合、式3とも表せる。
  defp circle_if_possible(c) when c <= @a_code_prev, do: @z_code - (@a_code_prev - c)
  defp circle_if_possible(c), do: c
end
