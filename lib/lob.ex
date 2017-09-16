defmodule Lob do
  require Poison
  require Chacha20

  @moduledoc """
  Length-Object-Binary (LOB) Packet Encoding

  Data serialization, primarily in use by the [Telehash Project](http://telehash.org)
  """

  @type maybe_binary :: binary | nil

  @doc """
  Decode a wire packet for consumption

  The parts are returned in a struct compliant with the specification.
  Errors reflecting improperly decoded JSON are stored in the `json` field.
  """
  @spec decode(binary) :: Lob.DecodedPacket.t | no_return
  def decode(<<s::size(16), rest::binary>>), do: rest |> decode_rest(s)

  @spec encode(maybe_binary | map , maybe_binary) :: binary | no_return
  @doc """
  Encode a head and body into a packet

  The packet should be usable across any supported transport.  May raise an
  exception if the payload is too large or there are encoding errors.
  """
  def encode(head, body) when is_nil(head),    do: encode("", body)
  def encode(head, body) when is_nil(body),    do: encode(head, "")
  def encode(head, body) when is_binary(head), do: head_size(head) <> head <> body
  def encode(head, body) when is_map(head),    do: encode(head |> Poison.encode!, body)

  defp head_size(s) when byte_size(s) <= 0xffff, do: << byte_size(s)::size(16) >>
  defp head_size(s) when byte_size(s) >  0xffff, do: raise("Head payload too large.")

  @spec decode_rest(binary, char) :: Lob.DecodedPacket.t
  defp decode_rest(r, _s) when r == "", do: %Lob.DecodedPacket{}
  defp decode_rest(r, s)  when s == 0,  do: Lob.DecodedPacket.__build__(nil, nil, r)
  defp decode_rest(r, s)                do
      << head::binary-size(s), body::binary >> = r
      json = if s <= 6 do
                nil
             else case head |> Poison.decode do
                       {:ok, j}        -> j
                       e               -> e
                  end
            end
      Lob.DecodedPacket.__build__(head, json, body)
  end

  # SHA256 of "telehash"
  defp cloak_key, do: <<215, 240, 229, 85, 84, 98, 65, 178, 169, 68, 236, 214, 208, 222, 102, 133, 106, 197, 11, 11, 171, 167, 106, 111, 90, 71, 130, 149, 108, 169, 69, 154>>

  @spec cloak(binary) :: binary
  @doc """
  Cloak a packet to frustrate wire monitoring

  A random number (between 1 and 20) of rounds are applied.  This also
  serves to slightly obfuscate the message size.
  """
  def  cloak(b), do: cloak_loop(b, :rand.uniform(20))
  defp cloak_loop(b, 0), do: b
  defp cloak_loop(b, rounds) do
    n = make_nonce()
    cloak_loop(n <> Chacha20.crypt(b, cloak_key(), n), rounds - 1)
  end

  defp make_nonce do
    n = :crypto.strong_rand_bytes(8)
    case binary_part(n, 0, 1) do
      <<0>> -> make_nonce()
      _     -> n
    end
  end


  @spec decloak(binary) :: Lob.DecodedPacket.t | no_return
  @doc """
  De-cloak a cloaked packet.

  Upon success, the decoded packet will have the number of cloaking rounds unfurled
  in the `cloaked` field.
  """
  def  decloak(b), do: decloak_loop(b, 0)
  defp decloak_loop(<<0, _rest::binary>> = b, r),               do: %{decode(b)  | "cloaked": r}
  defp decloak_loop(<<nonce::binary-size(8),  ct::binary>>, r), do: decloak_loop(Chacha20.crypt(ct, cloak_key(), nonce), r + 1)

end
