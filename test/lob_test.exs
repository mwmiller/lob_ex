defmodule LobTest do
  use PowerAssert
  doctest Lob

  test "Telehash example decode" do
    decoded_packet = Lob.decode(TelehashExample.hex_string, true)

    assert decoded_packet.head_length == TelehashExample.head_length
    assert decoded_packet.head == TelehashExample.head
    assert decoded_packet.json == TelehashExample.json
    assert decoded_packet.body_length == TelehashExample.body_length
    assert decoded_packet.body == TelehashExample.body

  end

  test "Telehash example encode" do
    assert Lob.encode(TelehashExample.head, TelehashExample.body) |> Base.encode16(case: :lower) == TelehashExample.hex_string
  end

  test "no message" do
    decoded_packet = Lob.encode(nil, nil) |> Lob.decode

    assert decoded_packet.head_length == 0
    assert decoded_packet.head == nil
    assert decoded_packet.json == nil
    assert decoded_packet.body_length == 0
    assert decoded_packet.body == nil
  end

  test "no body" do
    nil_body = Lob.encode(TelehashExample.head, nil)

    assert nil_body == Lob.encode(TelehashExample.head, "")

    back_out = Lob.decode(nil_body)

    assert back_out.body_length == 0
    assert back_out.body == nil
    assert back_out.head_length == TelehashExample.head_length
    assert back_out.head == TelehashExample.head
    assert back_out.json == TelehashExample.json
  end

  test "no head" do
    nil_head = Lob.encode(nil, TelehashExample.body)

    assert nil_head == Lob.encode("", TelehashExample.body)

    back_out = Lob.decode(nil_head)

    assert back_out.body_length == TelehashExample.body_length
    assert back_out.body == TelehashExample.body
    assert back_out.head_length == 0
    assert back_out.head == nil
    assert back_out.json == nil
  end

end
