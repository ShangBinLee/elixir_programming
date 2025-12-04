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
