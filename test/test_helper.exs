ExUnit.start()

defmodule TelehashExample do
  # Example from telehash JS tests
  def hex_string, do: "001d7b2274797065223a2274657374222c22666f6f223a5b22626172225d7d616e792062696e61727921"
  def head_length, do: 29
  def head, do: "{\"type\":\"test\",\"foo\":[\"bar\"]}"
  def json, do: %{"foo" => ["bar"], "type" => "test"}
  def body_length, do:  11
  def body, do: "any binary!"
end
