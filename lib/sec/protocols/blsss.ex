defmodule Sec.Protocol.BLSSS do
  use Overridable
  alias Sec.BLSNif, as: BLS

  @spec sign(integer, binary) :: %{msg: binary, sigma: binary}
  def sign(a,msg) do
    h = BLS.hash_G2(msg)
    a = BLS.new_R(String.to_integer(a))

    sigma = h * a

    %{
      msg: msg,
      sigma: to_bin(sigma)
    }
  end

  def verify(sigma, msg, bigA) do
    g = BLS.g1()
    h = BLS.hash_G2(msg)
    bigA = BLS.from_bin(:g1, bigA)
    sigma = BLS.from_bin(:g2, sigma)

    left = BLS.pairing(g, sigma)
    right = BLS.pairing(bigA, h)

    %{
      valid: left == right
    }
  end

end
