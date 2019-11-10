defmodule Sec.Protocol.Naxos do
  use Overridable
  alias Sec.BLSNif, as: BLS

  @b {:overridable, Sec.BLSNif, {:r, 38807091665597789440396495453512817843634908293254474559050171685434626232422}}
  @bigB {:overridable, Sec.BLSNif, {:g1, "1 2870722932065444469132351785878865365091896904859720043391754179675500588968972078480942753457053999883475894017157 250499134037570768163307396428964032899362507864909966335806595505375860960217128936682594987901248371241384762825"}}

  def rand(a) do
    a = a |> String.to_integer() |> BLS.new_R()
    g = BLS.g1()
    esk = :crypto.strong_rand_bytes(512) |> h2
    bigX = g * h1(esk <> to_bin(a))

    %{
      esk: esk |> Base.encode64(),
      X: to_bin(bigX)
    }
  end

  def exchange(bigA, bigX, msg) do
    %{esk: esk, X: bigY} = rand(to_bin(@b))
    {:ok, esk} = Base.decode64(esk)

    bigA = BLS.from_bin(:g1, bigA)
    bigX = BLS.from_bin(:g1, bigX)

    k = h2(to_bin(bigA * h1(esk <> to_bin(@b))) <> to_bin(bigX * @b) <> to_bin(bigX * h1(esk <> to_bin(@b))) <> to_bin(bigA) <> to_bin(@bigB))

    msg = h2(k <> msg) |> Base.encode64()

    %{
      Y: bigY,
      msg: msg
    }
  end

  def client(a, esk, bigY, bigB, msg) do
    {:ok, esk} = Base.decode64(esk)

    a = a |> String.to_integer() |> BLS.new_R()
    bigB = BLS.from_bin(:g1, bigB)
    bigY = BLS.from_bin(:g1, bigY)
    bigA = BLS.g1() * a

    k = h2(
      to_bin(bigY * a)
      <>
      to_bin(bigB * h1(esk <> to_bin(a)))
      <>
      to_bin(bigY * h1(esk <> to_bin(a)))
      <>
      to_bin(bigA)
      <>
      to_bin(bigB)
    )

    %{
      k: k |> Base.encode64(),
      msg: h2(k <> msg) |> Base.encode64()
    }
  end

  def pkey(), do: %{B: to_bin(@bigB)}

  defp h1(str) do
    :crypto.hash(:sha3_512, str) |> :binary.decode_unsigned() |> BLS.new_R()
  end

  defp h2(str) do
    :crypto.hash(:sha3_512, str)
  end

end
