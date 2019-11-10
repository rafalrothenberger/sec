defmodule Sec.Protocol.GJSS do
  use Overridable
  alias Sec.BLSNif, as: BLS

  def sign(a,msg) do
    g = BLS.g1()
    a = a |> String.to_integer() |> BLS.new_R()
    bigA = g * a
    r = BLS.random_R()
    h = BLS.hash_G1(msg <> to_bin(r))
    z = h * a
    k = BLS.random_R()
    u = g * k
    v = h * k
    c = :crypto.hash(:sha3_512, to_bin(g) <> to_bin(h) <> to_bin(bigA) <> to_bin(z) <> to_bin(u) <> to_bin(v)) |> :binary.decode_unsigned() |> BLS.new_R()
    s = k + c * a

    %{
      msg: msg,
      sigma: %{
        z: to_bin(z),
        r: to_bin(r),
        s: to_bin(s),
        c: to_bin(c)
      }
    }
  end

  def verify(%{z: z, r: r, s: s, c: c}, msg, bigA) do
    g = BLS.g1()
    r = r |> String.to_integer() |> BLS.new_R()
    z = BLS.from_bin(:g1, z)
    s = s |> String.to_integer() |> BLS.new_R()
    cm = c |> String.to_integer() |> Kernel.- |> BLS.new_R()
    c = c |> String.to_integer() |> BLS.new_R()
    bigA = BLS.from_bin(:g1, bigA)

    h = BLS.hash_G1(msg <> to_bin(r))

    u = (g * s) + (bigA * cm)
    v = (h * s) + (z * cm)
    cp = :crypto.hash(:sha3_512, to_bin(g) <> to_bin(h) <> to_bin(bigA) <> to_bin(z) <> to_bin(u) <> to_bin(v)) |> :binary.decode_unsigned() |> BLS.new_R()

    %{
      valid: cp == c
    }
  end

end
