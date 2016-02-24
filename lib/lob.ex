defmodule Lob do
  require Poison
  import Bitwise

  @type maybe_binary :: binary | nil

  @spec decode(binary, boolean) :: Lob.DecodedPacket.t | no_return
  def decode(packet, hex \\ false) do
      {:ok, << <<s::size(16)>>, <<rest::binary>> >>} = if hex, do: Base.decode16(packet, case: :mixed), else: {:ok, packet}
      rest |> decode_rest(s)
  end

  @spec encode(maybe_binary | map , maybe_binary) :: binary | no_return
  def encode(head,body) when is_nil(head),    do: encode("",body)
  def encode(head,body) when is_nil(body),    do: encode(head,"")
  def encode(head,body) when is_binary(head), do: head_size(head)<>head<>body
  def encode(head,body) when is_map(head),    do: encode(head |> Poison.encode!, body)

  defp head_size(s) when byte_size(s) <= 0xffff, do: << byte_size(s)::size(16) >>
  defp head_size(s) when byte_size(s) >  0xffff, do: raise("Head payload too large.")

  @spec decode_rest(binary, char) :: Lob.DecodedPacket.t
  defp decode_rest(r,_s) when r == "", do: %Lob.DecodedPacket{}
  defp decode_rest(r,s)  when s == 0,  do: Lob.DecodedPacket.__build__(nil,nil,r)
  defp decode_rest(r,s)  when s <= 6   do
      bits = 8 * s
      << <<h::size(bits)>>, <<b::binary>> >> = r
      Lob.DecodedPacket.__build__((h|>to_binary(s)), nil, b)
  end
  defp decode_rest(r,s) when s > 6 do
      bits = 8 * s
      << <<h::size(bits)>>, <<body::binary>> >> = r
      head = h |> to_binary(s)
      json = case head |> Poison.decode do
            {:ok, j}        -> j
            e               -> e
      end
      Lob.DecodedPacket.__build__(head, json, body)
  end

  @spec to_binary(integer, integer) :: binary
  defp to_binary(p,s) when is_integer(p), do: binary_from_integer(p, s, [])
  defp binary_from_integer(_p, 0, acc),   do: acc |> Enum.reverse |> Enum.join
  defp binary_from_integer(p, n, acc),    do: binary_from_integer(p, n-1, [<< (bsr(p,8*(n-1)) &&& 0xff) >>|acc])

end
