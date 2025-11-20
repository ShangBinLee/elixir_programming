defmodule Otp.Stack do
  @moduledoc """
  # 練習問題：OTP-Servers-1

  スタックを実装したサーバーを作り始めよう。スタックを初期化する呼び出しでは、\s\s
  スタックの開始時の中身となるリストが渡される。\s\s
  まずは、popインターフェースだけ実装してみよう。空のスタックから値をポップしよう\s\s
  としたら、クラッシュしても良いことにしよう。\s\s
  例えば、もし `[5, "cat", 9]`で初期化したのなら、連続したpopの呼び出しは、`5`、\s\s
  `"cat"`そして`9`を返す。

  """

  use GenServer

  def init(stack) do
    {:ok, stack}
  end

  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  def handle_call(:pop, _from, []) do
    {:reply, {:error, "空のスタックです。"}, []}
  end
end
