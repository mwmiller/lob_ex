ExUnit.start()

defmodule TelehashExample do
  # Example from telehash JS tests
  def test_string,
    do:
      "001d7b2274797065223a2274657374222c22666f6f223a5b22626172225d7d616e792062696e61727921"
      |> Base.decode16!(case: :lower)

  def head_length, do: 29
  def head, do: "{\"type\":\"test\",\"foo\":[\"bar\"]}"
  def json, do: %{"foo" => ["bar"], "type" => "test"}
  def body_length, do: 11
  def body, do: "any binary!"
end

defmodule TelehashCloaked do
  # Cloaked example from telehash JS tests
  def test_string,
    do:
      "b8921a332948eedec882b3102aa9d6de8688d73a195b0cab64bbf61f5c6805df85e901c1fb774046f46a43ba5440a5cad24eb486"
      |> Base.decode16!(case: :lower)

  def head_length, do: 18
  def head, do: "{\"test\":\"cloaked\"}"
  def json, do: %{"test" => "cloaked"}
  def body_length, do: 0
  def body, do: nil
  def cloaked, do: 4
end
