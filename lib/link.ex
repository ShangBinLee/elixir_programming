defmodule Link do
  import :timer, only: [sleep: 1]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    spawn_link(Link, :sad_function, [])
    receive do
      msg ->
        IO.puts "メッセージ受信：#{msg}"
      after 1000 ->
        IO.puts "何もなかった！"
    end
  end
end

Link.run()
