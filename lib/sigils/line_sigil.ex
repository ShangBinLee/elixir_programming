defmodule Sigils.LineSigil do
  @doc """
  入力された文字列を各行に分割した文字列のリストを返却するシジル。

  ## パラメータ

    - lines：シジルのデリミタで囲まれた文字列
    - _opts：デリミタの後に続くオプション（使わない）

  ## 例

      iex> import Sigils.LineSigil
      Sigils.LineSigil
      iex> ~l\"""
      ...> one
      ...> two
      ...> three
      ...> \"""
      ["one", "two", "three"]

  """
  def sigil_l(lines, _opts) do
    lines |> String.trim_trailing() |> String.split("\n")
  end
end
