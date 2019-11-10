defmodule Sec.Protocol.SIS do
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

  def verify(token, s) do
    GenServer.call(__MODULE__, {:verify, token, s})
  end

  def random() do
    x = BLS.random_R()
    g = BLS.g1()
    %{
      "x" => to_bin(x),
      "X" => to_bin(g * x)
    }
  end

  def client(a,x,c) do
    a = BLS.new_R(String.to_integer(a))
    x = BLS.new_R(String.to_integer(x))
    c = BLS.new_R(String.to_integer(c))

    %{
      "s" => to_bin(a * c + x)
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
      },
      protocol_name: :sis
    }

    {:reply, reply, Map.put_new(sessions, token, session)}
  end

  def handle_call({:verify, token, s}, _from, sessions) do
     reply = case Map.get(sessions, token, nil) do
       %{bigA: bigA, bigX: bigX, c: c} ->
        try do
          s = BLS.new(s)
          validate!(s, bigA, bigX, c)
        rescue
          _ -> 403
        end
       _ -> 403
     end

     {:reply, reply, Map.delete(sessions, token)}
  end

  defp validate!(s, bigA, bigX, c) do
    g = BLS.g1()

    left = g * s
    right = bigX + bigA * c
    if left == right do
      200
    else
      403
    end
  end

end
