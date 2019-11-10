defmodule Sec.Protocol.SSS do
  use Overridable
  alias Sec.BLSNif, as: BLS

  def verify(msg, bigX, s, bigA) do
    g = BLS.g1()
    s = BLS.new_R(s)
    h = BLS.hash_R(msg <> bigX)
    bigX = BLS.from_bin(:g1, bigX)
    bigA = BLS.from_bin(:g1, bigA)
    left = g * s
    right = bigX + (bigA * h)
    %{valid: left==right}
  end

  def sign(msg, a) do
    a = BLS.new_R(a)
    g = BLS.g1()
    x = BLS.random_R()
    bigX = g * x
    h = BLS.hash_R(msg <> to_bin(bigX))
    s = a * h + x
    %{
       s: to_bin(s),
       X: to_bin(bigX),
       msg: msg
    }
  end
end
