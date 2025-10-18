defmodule Functions do
  @moduledoc """
  第5章「無名関数」に載っている練習問題で興味深い問題の解答
  """

  @doc """
  # 練習問題：Functions-2

  対象の値`n`についてFizzBuzzを判定する為に

  `n`を3と5で割った余りと`n`を引数として受け取ってパターンマッチさせる。

  ## パラメータ

    - by_three（1番目）：`n`を3で割った余り
    - by_five（2番目）：`n`を5で割った余り
    - n（3番目）：対象の値

  ## 例

      iex> Functions.fizz_buzz_by_rem(rem(5, 3), rem(5, 5), 5)
      "Buzz"
      iex> Functions.fizz_buzz_by_rem(rem(1242, 3), rem(1242, 5), 1242)
      "Fizz"
      iex> Functions.fizz_buzz_by_rem(rem(30, 3), rem(30, 5), 30)
      "FizzBuzz"
      iex> Functions.fizz_buzz_by_rem(rem(11, 3), rem(11, 5), 11)
      11

  """
  @spec fizz_buzz_by_rem(by_three::integer(), by_five::integer(), n::integer()) :: String.t() | integer()
  def fizz_buzz_by_rem(by_three, by_five, n)
  def fizz_buzz_by_rem(0, 0, _) do
    "FizzBuzz"
  end
  def fizz_buzz_by_rem(0, _, _) do
    "Fizz"
  end
  def fizz_buzz_by_rem(_, 0, _) do
    "Buzz"
  end
  def fizz_buzz_by_rem(_, _, n) do
    n
  end

  @doc """
  # 練習問題：Functions-3

  `n`を受け取り、FizzBuzzを判定する。

  ## パラメータ

    - n：対象の値

  ## 例

      iex> Functions.fizz_buzz(5)
      "Buzz"
      iex> 10..16 |> Enum.map(&Functions.fizz_buzz/1)
      ["Buzz", 11, "Fizz", 13, 14, "FizzBuzz", 16]

  """
  @spec fizz_buzz(n::integer()) :: String.t() | integer()
  def fizz_buzz(n), do: fizz_buzz_by_rem(rem(n, 3), rem(n, 5), n)
end
