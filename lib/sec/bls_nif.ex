defmodule Sec.BLSNif do
  use Overridable.Strategy
  alias Overridable.Strategy.NotImplementedError

  @r      0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001
  @rand_a 0x4000000000000000000000000000000000000000000000000000000000000000
  @g1     "1 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569"
  @g2     "1 352701069587466618187139116011060144890029952792775240219908644239793785735715026873347600343865175952761926303160 3059144344244213709971259814753781636986470325476647558659373206291635324768958432433509563104347017837885763365758 1985150602287291935568054521177171638300868978215655730859378665066344726373823718423869104263333984641494340347905 927553665492332455747201965776037880757740193453592970025027978793976877002675564980949289727957565575433344219582"

  # Public API
  def new_G1(a), do: new({:g1, a})

  def new_G2(a), do: new({:g2, a})

  def new_R(a), do: new({:r, a})

  def g1(), do: new({:g1, @g1})

  def g2(), do: new({:g2, @g2})

  def from_bin(group, a) when group in [:g1,:g2] and is_binary(a), do: new({group, "1 " <>  a})

  def from_bin(:r, a) when is_binary(a), do: from_bin(String.to_integer(a))

  def from_bin(a) when is_integer(a), do: new({:r, a})

  def random_R(), do: Overridable.random(new({:r, 0}))

  def random_G1(), do: Overridable.random(new({:g1, ""}))

  def random_G2(), do: Overridable.random(new({:g2, ""}))

  def hash_G1(str) when is_binary(str) do
    BlsNif.g1hash(str) |> new_G1()
  end

  def hash_G2(str) when is_binary(str) do
    BlsNif.g2hash(str) |> new_G2()
  end

  def hash_R(str) when is_binary(str) do
    :binary.decode_unsigned(:crypto.hash(:sha3_512, str)) |> new_R()
  end

  def pairing({:overridable, Sec.BLSNif, {:g1, a}}, {:overridable, Sec.BLSNif, {:g2, b}}) do
    BlsNif.pairing(a, b)
  end

  # Overridable API
  def over_new({:g1, a}) when is_binary(a), do: {:g1, a}

  def over_new({:g2, a}) when is_binary(a), do: {:g2, a}

  def over_new({:r, a}) when is_binary(a), do: over_new(String.to_integer(a))

  def over_new({:r, a}) when is_integer(a), do: {:r, mod(a, @r)}

  def over_new(r) when is_integer(r), do: over_new({:r, r})

  def over_to_bin({group, a}) when group in [:g1, :g2] and is_binary(a) do
    << "1 ", rest :: binary >> = a
    rest
  end

  def over_to_bin({:r, a}) when is_integer(a), do: Integer.to_string(a)

  def over_neg({:g1, a}) when is_binary(a) do
    {:g1, BlsNif.g1neg(a)}
  end

  def over_neg({:g2, a}) when is_binary(a) do
    {:g2, BlsNif.g2neg(a)}
  end

  def over_neg({:r, a}) when is_integer(a) do
    {:r, mod(-a, @r)}
  end

  def over_add({:g1, a}, {:g1, b}) when is_binary(a) and is_binary(b) do
    {:g1, BlsNif.g1add(a, b)}
  end

  def over_add({:g2, a}, {:g2, b}) when is_binary(a) and is_binary(b) do
    {:g2, BlsNif.g2add(a, b)}
  end

  def over_add({:r, a}, {:r, b}) when is_integer(a) and is_integer(b) do
    {:r, mod(a+b, @r)}
  end

  def over_sub({:g1, a}, {:g1, b}) when is_binary(a) and is_binary(b) do
    {:g1, BlsNif.g1sub(a, b)}
  end

  def over_sub({:g2, a}, {:g2, b}) when is_binary(a) and is_binary(b) do
    {:g2, BlsNif.g2sub(a, b)}
  end

  def over_sub({:r, a}, {:r, b}) when is_integer(a) and is_integer(b) do
    {:r, mod(a-b, @r)}
  end

  def over_mul({:g1, a}, {:r, b}) when is_binary(a) and is_integer(b) do
    {:g1, BlsNif.g1mul(a, b)}
  end

  def over_mul({:g2, a}, {:r, b}) when is_binary(a) and is_integer(b) do
    {:g2, BlsNif.g2mul(a, b)}
  end

  def over_mul({:r, a}, {:r, b}) when is_integer(a) and is_integer(b) do
    {:r, mod(a*b, @r)}
  end

  def over_random({:r, _}), do: {:r, :crypto.rand_uniform(@rand_a, @r)}

  def over_random({:g1, _}), do: raise(NotImplementedError, "random for G1")

  def over_random({:g2, _}), do: raise(NotImplementedError, "random for G2")

  # Private API
  defp mod(a, n) when is_integer(a) and a > 0, do: rem(a,n)

  defp mod(a, n) when is_integer(a), do: rem(rem(a,n)+n, n)
end
