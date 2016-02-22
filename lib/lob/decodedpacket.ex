defmodule Lob.DecodedPacket do

  defstruct head_length: 0, head: nil, json: nil, body_length: 0, body: nil
  @type t :: %__MODULE__{}

  @doc false
  def __build__(nil,nil,b), do: %Lob.DecodedPacket{body_length: byte_size(b), body: b,}
  def __build__(h,j,b) when b == "", do: %Lob.DecodedPacket{head_length: byte_size(h), head: h, json: j,}
  def __build__(h,j,b), do: %Lob.DecodedPacket{head_length: byte_size(h),
                                                        head:        h,
                                                        json:        j,
                                                        body_length: byte_size(b),
                                                        body:        b,
                                                       }
end
