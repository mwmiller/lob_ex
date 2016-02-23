defmodule Lob do
  require Poison

  @type maybe_binary :: binary | nil

  @spec decode(binary, boolean) :: Lob.DecodedPacket.t | no_return
  def decode(packet, hex \\ false) do
      {:ok, << <<s::size(16)>>, <<rest::binary>> >>} = if hex, do: Base.decode16(packet, case: :mixed), else: {:ok, packet}
      rest |> decode_rest(s)
  end

  @spec encode(maybe_binary | map , maybe_binary) :: binary | no_return
  def encode(nil,nil),                        do: head_size("")
  def encode(nil,body),                       do: head_size("")<>body
  def encode(head,nil)  when is_binary(head), do: head_size(head)<>head
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
      Lob.DecodedPacket.__build__((h|>to_binary), nil, b)
  end
  defp decode_rest(r,s) when s > 6 do
      bits = 8 * s
      << <<h::size(bits)>>, <<body::binary>> >> = r
      head = h |> to_binary
      json = case head |> Poison.decode do
            {:ok, j}        -> j
            e               -> e
      end
      Lob.DecodedPacket.__build__(head, json, body)
  end

  @spec to_binary(integer) :: binary
  defp to_binary(p) when is_integer(p) do
    {:ok, s} = p |> Integer.to_string(16) |> Base.decode16
    s
  end

end
