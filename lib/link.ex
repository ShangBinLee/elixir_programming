defmodule Link do
  import :timer, only: [sleep: 1]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    Process.flag(:trap_exit, true)
    spawn_link(Link, :sad_function, [])
    receive do
      msg ->
        IO.puts "メッセージ受信：#{inspect msg}"
      after 1000 ->
        IO.puts "何もなかった！"
    end
  end
end

Link.run()
