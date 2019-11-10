defmodule SecWeb.Protocols.SssController do
  use SecWeb, :controller


  def verify(conn, %{"payload" => %{"A" => bigA, "msg" => msg, "s" => s, "X" => bigX}}) do
    x = Sec.Protocol.SSS.verify(msg, bigX, String.to_integer(s), bigA)
    require Logger
    Logger.debug("#{inspect x}")
    conn
    |> json(x)
  end

  def client(conn, %{"msg" => msg, "a" => a}) do
    # try do
      conn
      |> json(Sec.Protocol.SSS.sign(msg, String.to_integer(a)))
    # rescue
    #   _ ->
    #     conn
    #     |> put_status(500)
    #     |> json(%{error: "Something went wrong..."})
    # end
  end

end
