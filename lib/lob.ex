defmodule Lob do
  require Poison
  require Chacha20

  @type maybe_binary :: binary | nil

  @spec decode(binary) :: Lob.DecodedPacket.t | no_return
  def decode(packet) do
      << <<s::size(16)>>, <<rest::binary>> >> = packet
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
      Lob.DecodedPacket.__build__((h|>:binary.encode_unsigned), nil, b)
  end
  defp decode_rest(r,s) when s > 6 do
      bits = 8 * s
      << <<h::size(bits)>>, <<body::binary>> >> = r
      head = h |> :binary.encode_unsigned
      json = case head |> Poison.decode do
            {:ok, j}        -> j
            e               -> e
      end
      Lob.DecodedPacket.__build__(head, json, body)
  end

  # SHA256 of "telehash"
  defp cloak_key, do: <<215, 240, 229, 85, 84, 98, 65, 178, 169, 68, 236, 214, 208, 222, 102, 133, 106, 197, 11, 11, 171, 167, 106, 111, 90, 71, 130, 149, 108, 169, 69, 154>>

  @spec cloak(binary) :: binary
  @doc """
  Cloak a packet to frustrate wire monitoring

  A random number (between 1 and 20) rounds are applied.  This also
  serves to slightly obfuscate the message size.
  """
  def  cloak(b), do: cloak_loop(b, :crypto.rand_uniform(1,20))
  defp cloak_loop(b,0), do: b
  defp cloak_loop(b,rounds) do
    n = make_nonce
    cloak_loop(n<>Chacha20.crypt(b,cloak_key,n), rounds - 1)
  end

  defp make_nonce do
    n = :crypto.strong_rand_bytes(8)
    if (binary_part(n,0,1) == <<0>>) do
      make_nonce
    else
      n
    end
  end


  @spec decloak(binary) :: Lob.DecodedPacket.t | no_return
  @doc """
  De-cloak a cloaked packet.

  Upon success, the decoded packet will have the number of cloaking rounds unfurled
  in the `cloaked` property.
  """
  def decloak(b), do: decloak_loop(b, 0)
  def decloak_loop(b,r) do
    if (binary_part(b, 0, 1) == <<0>>) do
        %{decode(b)  | "cloaked": r}
    else
      <<nonce::size(64), ct::binary>> = b
      decloak_loop(Chacha20.crypt(ct,cloak_key,:binary.encode_unsigned(nonce)), r+1)
    end
  end

end
