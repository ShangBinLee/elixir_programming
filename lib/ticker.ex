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

  ## パラメータ

    - module：通知サーバーのモジュール
      - インターフェースとして`register/1`関数が必要
  """
  def start(module) do
    pid = spawn(__MODULE__, :receiver, [])
    module.register(pid)
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

defmodule Ticker3 do
  @moduledoc """
  # 練習問題：Nodes-3

  登録されたクライアントが順々に通知を受け取るようにコードを変更しよう。\s\s
  つまり、最初の時報が最初に登録されたクライアントに届き、次の時報が\s\s
  次のクライアントに届き、⋯。となるようにする。最後のクライアントへ送った後は、\s\s
  また最初に戻る。回答のコードでも、クライアントをいつでも追加できなければならない。

  """

  @interval 2000 # 2秒
  @name :ticker3
  def start do
    pid = spawn(__MODULE__, :generator, [{[], []}])
    :global.register_name(@name, pid)
  end

  def register(client_pid) do
    send :global.whereis_name(@name), {:register, client_pid}
  end

  @doc """
  循環通知サーバープロセス

  ## イベント

    - {:register, pid}：クライアントを通知キューの最後に追加
    - after @interval：通知を次の対象クライアントに送る

  """
  def generator(queue) do
    receive do
      {:register, pid} ->
        IO.puts "クライアント登録：#{inspect pid}"

        queue
        |> _add_queue(pid)
        |> generator()

      after @interval ->
        IO.puts "tick"

        case _next_queue(queue) do
          # キューを一歩進める
          {:none, queue_next} ->
            # クライアントが一個も登録されてない
            generator(queue_next)
          {next_client, queue_next} ->
            # クライアントが一個以上登録されている
            send next_client, {:tick}
            generator(queue_next)
        end
    end
  end

  defp _add_queue({prev, next}, el), do: {prev, next ++ [el]}

  defp _forward_queue({_prev = [], _next = []}) do
    {[], []}
  end
  defp _forward_queue({prev, _next = [next_el]}) do
    {[], Enum.reverse([next_el | prev])}
  end
  defp _forward_queue({prev, _next = [head | tail]}) do
    {[head | prev], tail}
  end

  defp _get_queue({_prev, _next = []}), do: :none
  defp _get_queue({_prev, _next = [head | _tail]}), do: head

  defp _next_queue(queue) do
    queue
    |> (&{_get_queue(&1), _forward_queue(&1)}).()
  end
end

defmodule ClientRing do
  @moduledoc """
  # 練習問題：Nodes-4
  この章で紹介した通知プロセスは、登録されたクライアントにイベントを送る\s\s
  中央サーバーだった。これを、クライアントのリング（輪）として再実装しよう。\s\s
  クライアントは通知をリング上の次のクライアントに送る。その2秒後に、先ほど\s\s
  通知を受け取ったクライアントは次のクライアントに通知を送る。\s\s
  リングにクライアントを加える方法について考えるときは、新しいプロセスを加える\s\s
  時と同じように、クライアントの受信ループがタイムアウトした場合の取り扱いについても\s\s
  留意しよう。どういうことかというと、「誰がリングの更新の責任を負うのか？」という問題だ。

  """

  @interval 2000 # 2秒
  @tail_name :client_ring_tail
  def start do
    pid = spawn(__MODULE__, :circulator, [nil, false])

    tail = case name = :global.whereis_name(@tail_name) do
      :undefined ->
        # 初のプロセスなので自分を設定
        pid
      _ ->
        # 既存の末尾
        name
    end

    send tail, {:register, pid}
  end

  def circulator(next, will_tick) do
    receive do
      {:register, pid} ->
        case is_nil(next) do
          true ->
            # 新規プロセス（新しい末尾）
            :global.re_register_name(@tail_name, self())
          false ->
            # 既存プロセス（既存の末尾）
            send pid, {:register, next}
        end

        if pid === self() do
          # このリングで初のプロセスなのでtick開始
          send pid, {:tick, self()}
        end

        # nextを新しい末尾（既存の末尾の場合）
        # または既存のヘッド（新しい末尾の場合）
        # に置き換える
        circulator(pid, will_tick)
      {:tick, pid} ->
        IO.puts "#{inspect pid}からの通知メッセージ受信：tick"
        # 次のタイムアウトではtickする
        circulator(next, true)
      after @interval ->
        case will_tick do
          true ->
            send next, {:tick, self()}
            circulator(next, false)
          false ->
            circulator(next, false)
        end
    end
  end
end
