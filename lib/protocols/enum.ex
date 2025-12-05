defmodule Protocols.Enum do
  @moduledoc """
  # 練習問題：Protocols-3

  `Enumerable`プロトコルを実装しているコレクションは`count`と`member?`、`reduce`\s\s
  そして`slice`関数を定義している。`Enum`モジュールではそれらの関数を使って`each`、\s\s
  `filter`、`map`といった関数を実装している。\s\s
  `reduce`を使って、自前の`each`、`filter`、`map`を実装してみよう。

  """
  def each(enumerable, fun) do
    enumerable
    |> Enumerable.reduce(
      {:cont, :nil},
      fn el, :nil ->
        fun.(el)
        {:cont, :nil}
      end)

    :ok
  end

  # Enumerable.reduceの戻り値を扱う
  def reverse({:done, enumerable}), do: reverse(enumerable)

  def reverse(enumerable) do
    enumerable
    |> Enumerable.reduce(
      {:cont, []},
      fn el, acc ->
        {:cont, [el | acc]}
      end)
    |> (fn {:done, result} -> result end).()
  end

  def filter(enumerable, fun) do
    enumerable
    |> Enumerable.reduce(
      {:cont, []},
      fn el, acc ->
        if fun.(el) === true do
          {:cont, [el | acc]}
        else
          {:cont, acc}
        end
      end)
    |> reverse()
  end

  def map(enumerable, fun) do
    enumerable
    |> Enumerable.reduce(
      {:cont, []},
      fn el, acc ->
        {:cont, [fun.(el) | acc]}
      end)
    |> reverse()
  end
end
