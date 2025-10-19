defmodule StringsBinaries do
  @moduledoc """
  シングルクオート文字列、ダブルクオート文字列、バイナリ関連のモジュール
  """

  @doc """
  # 練習問題：StringsAndBinaries-2

  2つのシングルクオート文字列がアナグラムであるかを判別する。

  ## 例

      iex> StringsBinaries.anagram?(~c'かたい', ~c'たかい')
      true
      iex> StringsBinaries.anagram?(~c'あらす', ~c'あすら')
      true
      iex> StringsBinaries.anagram?(~c'するどい', ~c'すてきな')
      false
      iex> StringsBinaries.anagram?(~c'おはよう', ~c'こんにちは')
      false
      iex> StringsBinaries.anagram?("めしあげ", "しめあげ")
      ** (ArgumentError) argument error

  """
  @spec anagram?(charlist(), charlist()) :: boolean()
  def anagram?(word1, word2), do: _empty?(word1 -- word2) and _empty?(word2 -- word1)
  defp _empty?([]), do: true
  defp _empty?(_), do: false
end
