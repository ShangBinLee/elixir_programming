defprotocol Encryption do
  @moduledoc """
  # 練習問題：Protocols-1

  基本的なシーザー暗号は、メッセージ文字を固定のオフセットの分だけシフトすることで成立している。\s\s
  オフセットが`1`なら、例えば`a`は`b`に、`b`は`c`に、そして`z`は`a`になる。オフセットが13のものは、\s\s
  ROT13アルゴリズムとして知られている。\s\s
  リストとバイナリは文字列のようなものだ。この二つの型に対応するシーザープロトコルを書こう。\s\s
  作成するプロトコルは、二つの関数`encrypt(string, shift)`と`rot13(string)`を含めよう。

  """
  def encrypt(string, shift)

  def rot13(string)
end

defmodule Protocol.Helper do
  @a_code 97 # 一番小さいコード
  @z_code 122 # 一番大きいコード
  def first_code(), do: @a_code
  def last_code(), do: @z_code

  def shift(char, 0), do: char

  def shift(char, shift) do
    shifted = char + 1

    if shifted > @z_code do
      shift(@a_code, shift - 1)
    else
      shift(shifted, shift - 1)
    end
  end
end

defimpl Encryption, for: List do
  import Protocol.Helper, only: [shift: 2]

  def encrypt(string, shift) do
    string
    |> Enum.map(&shift(&1, shift))
  end

  def rot13(string) do
    encrypt(string, 13)
  end
end

defimpl Encryption, for: BitString do
  import Protocol.Helper

  def encrypt(<<>>, _), do: <<>>

  def encrypt(<<char::utf8, tail::bitstring>>, shift) do
    if first_code() <= char
      and char <= last_code()
    do
      <<shift(char, shift)>> <> encrypt(tail, shift)
    end
  end

  def rot13(string) do
    encrypt(string, 13)
  end
end
