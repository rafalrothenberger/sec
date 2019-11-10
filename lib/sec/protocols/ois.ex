defmodule Sec.Protocol.OIS do
  use GenServer
  use Overridable
  alias Sec.BLSNif, as: BLS

  @g1 BLS.g1()
  @g2 BLS.new_G1("1 2144250947445192081071618466765046647019257686245947349033844530891338159027816696711238671324221321317530545114427 2665798332422762660334686159210698639947668680862640755137811598895238932478193747736307724249253853210778728799013")


  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  def init(_) do
    {:ok, %{}}
  end

  def init(bigA, bigX) do
    GenServer.call(__MODULE__, {:init, bigA, bigX})
  end

  def verify(token, s1, s2) do
    GenServer.call(__MODULE__, {:verify, token, s1, s2})
  end

  def get_keys do
    a1 = BLS.random_R()
    a2 = BLS.random_R()
    bigA = @g1 * a1 + @g2 * a2
    {
      to_bin(a1),
      to_bin(a2),
      to_bin(bigA)
    }
  end

  def pub_key(a1, a2), do: @g1 * a1 + @g2 * a2

  def random() do
    g1 = @g1
    g2 = @g2
    x1 = BLS.random_R()
    x2 = BLS.random_R()
    bigX = g1 * x1 + g2 * x2
    %{
      x1: to_bin(x1),
      x2: to_bin(x2),
      X: to_bin(bigX),
    }
  end

  def client(a1, a2, x1, x2, c) do
    a1 = BLS.new_R(String.to_integer(a1))
    a2 = BLS.new_R(String.to_integer(a2))
    x1 = BLS.new_R(String.to_integer(x1))
    x2 = BLS.new_R(String.to_integer(x2))
    c = BLS.new_R(String.to_integer(c))
    %{
      s1: to_bin(x1 + (a1 * c)),
      s2: to_bin(x2 + (a2 * c))
    }
  end

  def handle_call({:init, bigA, bigX}, _from, sessions) do
    token = :crypto.strong_rand_bytes(256) |> Base.encode64()
    c = BLS.random_R()


    session = %{
      bigA: BLS.from_bin(:g1, bigA),
      bigX: BLS.from_bin(:g1, bigX),
      c: c
    }

    reply = %{
      session_token: token,
      payload: %{
        c: to_bin(c)
      }
    }

    {:reply, reply, Map.put_new(sessions, token, session)}
  end

  def handle_call({:verify, token, s1, s2}, _from, sessions) do
     reply = case Map.get(sessions, token, nil) do
       %{bigA: bigA, bigX: bigX, c: c} ->
        # try do
          s1 = BLS.new_R(String.to_integer(s1))
          s2 = BLS.new_R(String.to_integer(s2))
          validate!(s1, s2, bigA, bigX, c)
      #   rescue
      #     _ -> 403
      #   end
       _ -> 403
     end

     {:reply, reply, Map.delete(sessions, token)}
  end

  defp validate!(s1, s2, bigA, bigX, c) do
    g1 = @g1
    g2 = @g2
    left = g1 * s1 + g2 * s2
    right = bigX + bigA * c

    if left == right do
      200
    else
      403
    end
  end

end
