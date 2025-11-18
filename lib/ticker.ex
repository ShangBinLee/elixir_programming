defmodule Ticker do
  @moduledoc """
  定期的にクライアントにTick通知を送るサーバーとその外部インターフェースのモジュール
  """

  @interval 2000 # 2秒
  @name :ticker

  @doc """
  サーバーを起動し、そのpidにグローバルな名前を付ける。
  """
  def start do
    pid = spawn(__MODULE__, :generator, [[]])
    :global.register_name(@name, pid)
  end

  @doc """
  対象クライアントプロセスをサーバーに登録させるメッセージを送信する。

  クライアント側でサーバーにメッセージを直接送らないよう、\s\s
  関数としてのインターフェースを提供する。

  """
  def register(client_pid) do
    send :global.whereis_name(@name), {:register, client_pid}
  end

  @doc """
  通知サーバープロセス

  ## イベント

    - {:register, pid}：クライアント登録を行う
    - after @interval：通知を全クライアントに送る

  """
  def generator(clients) do
    receive do
      {:register, pid} ->
        IO.puts "クライアント登録：#{inspect pid}"
        generator([pid | clients])
      after @interval ->
        IO.puts "tick"
        for client <- clients do
          send client, {:tick}
        end
        generator(clients)
    end
  end
end

defmodule Client do
  @moduledoc """
  通知サーバーのクライアント
  """

  @doc """
  クライアントを起動し、\s\s
  グローバルな名前で登録されている通知サーバーに登録する。

  """
  def start do
    pid = spawn(__MODULE__, :receiver, [])
    Ticker.register(pid)
  end

  @doc """
  クライアントプロセス

  ## イベント

    - {:tick}：サーバーからの通知を処理する。

  """
  def receiver do
    receive do
      {:tick} ->
        IO.puts "クライアントでメッセージ受信：tick"
        receiver()
    end
  end
end
