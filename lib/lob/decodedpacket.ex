defmodule Lob.DecodedPacket do

  @moduledoc """
  A struct representing a decoded LOB packet

  The following fields are available:

  - head_length: the length of the encoded HEAD
  - head: HEAD contents
  - json: the decoded HEAD object, if appropriate
  - body_length: the length of the encoded BODY
  - body: BODY contents
  - cloaked: the number of cloaking rounds unwrapped
  """

  defstruct head_length: 0, head: nil, json: nil, body_length: 0, body: nil, cloaked: 0
  @type t :: %__MODULE__{}

  @doc false
  def __build__(nil,nil,b),          do: %Lob.DecodedPacket{body_length: byte_size(b),
                                                            body: b,
                                                           }
  # As a sort of implementation detail, body is not nil here, just ""
  def __build__(h,j,b) when b == "", do: %Lob.DecodedPacket{head_length: byte_size(h),
                                                            head: h,
                                                            json: j,
                                                            }
  def __build__(h,j,b),              do: %Lob.DecodedPacket{head_length: byte_size(h),
                                                            head:        h,
                                                            json:        j,
                                                            body_length: byte_size(b),
                                                            body:        b,
                                                           }
end
