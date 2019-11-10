defmodule Sec.Protocol.MSIS do
  use GenServer
  use Overridable
  alias Sec.BLSNif, as: BLS

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  def init(_) do
    {:ok, %{}}
  end

  def init(bigA, bigX) do
    GenServer.call(__MODULE__, {:init, bigA, bigX})
  end

  def verify(token, bigS) do
    GenServer.call(__MODULE__, {:verify, token, bigS})
  end

  def random() do
    x = BLS.random_R()
    g1 = BLS.g1()
    %{
      "x" => to_bin(x),
      "X" => to_bin(g1 * x)
    }
  end

  def client(a,x,c) do
    a = BLS.new_R(String.to_integer(a))
    x = BLS.new_R(String.to_integer(x))
    c = BLS.new_R(String.to_integer(c))
    # bigX = BLS.from_bin(:g1, bigX)
    bigX = BLS.g1() * x

    g_head = BLS.hash_G2(to_bin(bigX) <> to_bin(c))
    bigS = g_head * (x + (a*c))

    %{
      "S" => to_bin(bigS)
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

  def handle_call({:verify, token, bigS}, _from, sessions) do
     reply = case Map.get(sessions, token, nil) do
       %{bigA: bigA, bigX: bigX, c: c} ->
        # try do
          bigS = BLS.from_bin(:g2, bigS)
          validate!(bigS, bigA, bigX, c)
        # rescue
        #   _ ->
        #     403
        # end
       _ ->
          403
     end

     {:reply, reply, Map.delete(sessions, token)}
  end

  defp validate!(bigS, bigA, bigX, c) do
    g1 = BLS.g1()
    g_head = BLS.hash_G2(to_bin(bigX) <> to_bin(c))

    left = BLS.pairing(g1, bigS)
    right = BLS.pairing(bigX + bigA * c, g_head)
    if left == right do
      200
    else
      403
    end
  end

end
