defmodule Spawn do
  def greet do
    # この関数は繰り返し処理をしていない。
    receive do
      {sender, msg} ->
        send sender, {:ok, "初めまして！#{msg}さん。"}
    end
  end
end

pid = spawn(Spawn, :greet, [])

# 1回目の送信（受信成功）
send pid, {self(), "かなえ"}

receive do
  {:ok, msg} ->
    IO.puts msg
end

# 2回目の送信（待ち続ける）
send pid, {self(), "滝口"}

receive do
  {:ok, msg} ->
    IO.puts msg
  after 500 -> # 500ミリ秒でタイムアウト
    IO.puts "お迎えを忘れたみたいです。"
end
