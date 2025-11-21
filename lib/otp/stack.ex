defmodule Otp.Stack do
  @moduledoc """
  # 練習問題：OTP-Servers-1

  スタックを実装したサーバーを作り始めよう。スタックを初期化する呼び出しでは、\s\s
  スタックの開始時の中身となるリストが渡される。\s\s
  まずは、popインターフェースだけ実装してみよう。空のスタックから値をポップしよう\s\s
  としたら、クラッシュしても良いことにしよう。\s\s
  例えば、もし `[5, "cat", 9]`で初期化したのなら、連続したpopの呼び出しは、`5`、\s\s
  `"cat"`そして`9`を返す。

  # 練習問題：OTP-Servers-2

  この前の練習問題で作ったスタックサーバに、\s\s
  値をスタックのトップに追加するpushインターフェースを追加しよう。\s\s
  castを使って実装できる。\s\s
  IExで、値をプッシュしたりポップしたりしてみよう。

  # 練習問題：OTP-Servers-4

  スタックモジュールにAPI（GenServerの呼び出しをラップする関数）を加えよう。

  """

  use GenServer

  # 外部API

  def start_link(stack) do
    GenServer.start_link(__MODULE__, stack, name: __MODULE__)
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def push(el) do
    GenServer.cast(__MODULE__, {:push, el})
  end

  # GenServerの実装

  def init(stack) do
    {:ok, stack}
  end

  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  def handle_call(:pop, _from, []) do
    {:reply, {:error, "空のスタックです。"}, []}
  end

  def handle_cast({:push, el}, stack) do
    {:noreply, [el | stack]}
  end
end
