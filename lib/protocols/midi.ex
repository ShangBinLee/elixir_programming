defmodule Protocols.Midi do
  defstruct(content: <<>>)

  defmodule Frame do
    defstruct(
      type: "xxxx",
      length: 0,
      data: <<>>
    )

    def to_binary(%__MODULE__{type: type, length: length, data: data}) do
      <<
        type::binary-4,
        length::integer-32,
        data::binary
      >>
    end
  end

  def from_file(name) do
    %__MODULE__{content: File.read!(name)}
  end
end

defimpl Enumerable, for: Protocols.Midi do
  def _reduce(_content, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def _reduce(content, {:suspend, acc}, fun) do
    {:suspended, acc, &_reduce(content, &1, fun)}
  end
  def _reduce(_content = "", {:cont, acc}, _fun) do
    {:done, acc}
  end

  def _reduce(
    <<
      type::binary-4,
      length::integer-32,
      data::binary-size(length),
      rest::binary
    >>,
    {:cont, acc},
    fun
  ) do
    frame = %Protocols.Midi.Frame{type: type, length: length, data: data}
    _reduce(rest, fun.(frame, acc), fun)
  end

  def reduce(%Protocols.Midi{content: content}, state, fun) do
    _reduce(content, state, fun)
  end

  def count(midi=%Protocols.Midi{}) do
    frame_count = Enum.reduce(midi, 0, fn _, count -> count + 1 end)
    {:ok, frame_count}
  end

  def member?(%Protocols.Midi{}, %Protocols.Midi.Frame{}) do
    {:error, __MODULE__}
  end

  def slice(%Protocols.Midi{}) do
    {:error, __MODULE__}
  end
end

defimpl Collectable, for: Protocols.Midi do
  def into(%Protocols.Midi{content: content}) do
    {
      content,
      fn
        acc, {:cont, frame = %Protocols.Midi.Frame{}} ->
          acc <> Protocols.Midi.Frame.to_binary(frame)
        acc, :done ->
          %Protocols.Midi{content: acc}
        _, :halt ->
          :ok
      end
    }
  end
end

defimpl Inspect, for: Protocols.Midi do
  def inspect(%Protocols.Midi{content: <<>>}, _opts) do
    "#Midi[<<empty>>]"
  end

  def inspect(midi = %Protocols.Midi{}, _opts) do
    content =
      Enum.map(midi, fn frame -> inspect frame end)
      |> Enum.join("\n")
    "#Midi[\n#{content}\n]"
  end
end

defimpl Inspect, for: Protocols.Midi.Frame do
  def inspect(%Protocols.Midi.Frame{
    type: "MThd",
    length: 6,
    data: <<
      format::integer-16,
      tracks::integer-16,
      division::bits-16
    >>},
    _opts) do
    beats = decode(division)
    "#Midi.Header{Midi format: #{format}, tracks: #{tracks}, timing: #{beats}}"
  end

  def inspect(%Protocols.Midi.Frame{
    type: "MTrk",
    length: length,
    data: data
  },
  _opts) do
    "#Midi.Track{length: #{length}, data: #{inspect data}}"
  end

  def decode(<<0::1, beats::15>>) do
    "♪ = #{beats}"
  end

  def decode(<<1::1, fps::7, beats::8>>) do
    "#{-fps} fps, #{beats}/frame"
  end
end
