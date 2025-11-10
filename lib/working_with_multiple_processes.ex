defmodule WorkingWithMultipleProcesses do
  @moduledoc """
  第15章「複数のプロセスを使う」に載っている練習問題で興味深い問題の解答
  """

  defmodule FredBetty do
    @moduledoc """
    # 練習問題：WorkingWithMultipleProcesses-2

    二つのプロセスを生成し、それぞれのプロセスにユニークなトークンを渡すプログラム\s\s
    を作ろう。プロセスは受け取ったトークンを送り返すようにする。
      - プロセスから戻ってくる返事の順序は理論的に決定的であるか？ 実際は？
      - もしその答えが「No」であるなら、どうすれば順序を決定的にできるだろうか？
    """

    def send_token_to(name, token) do
      receive do
        send_to when is_pid(send_to) -> # 送信先はrun関数から
          send send_to, token
          send_token_to(name, token) # トークン待ち受ける
        token when is_atom(token) ->
          IO.puts("#{name}がトークン「#{token}」を受け取りました。")
      end
    end

    def run() do
      fred_p = spawn(WorkingWithMultipleProcesses.FredBetty, :send_token_to, ["fred", :fred])
      betty_p = spawn(WorkingWithMultipleProcesses.FredBetty, :send_token_to, ["betty", :betty])

      send fred_p, betty_p
      send betty_p, fred_p
    end
  end
end
