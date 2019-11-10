defmodule SecWeb.Protocols.NaxosController do
  use SecWeb, :controller

  def rand(conn, %{"a" => a}) do
    conn
    |> json(Sec.Protocol.Naxos.rand(a))
  end

  def exchange(conn, %{"payload" => %{"A" => bigA, "X" => bigX, "msg" => msg}}) do
    conn
    |> json(Sec.Protocol.Naxos.exchange(bigA, bigX, msg))
  end

  def client(conn, %{"a" => a, "esk" => esk, "Y" => bigY, "B" => bigB, "msg" => msg}) do
    conn
    |> json(Sec.Protocol.Naxos.client(a, esk, bigY, bigB, msg))
  end

  def pkey(conn, _params) do
    conn
    |> json(Sec.Protocol.Naxos.pkey())
  end

end
