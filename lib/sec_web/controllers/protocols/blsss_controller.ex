defmodule SecWeb.Protocols.BlsssController do
  use SecWeb, :controller


  def verify(conn, %{"payload" => %{"sigma" => sigma, "msg" => msg, "A" => bigA}}) do
    conn
    |> json(Sec.Protocol.BLSSS.verify(sigma, msg, bigA))
  end

  def sign(conn, %{"msg" => msg, "a" => a}) do
    try do
      conn
      |> json(Sec.Protocol.BLSSS.sign(a, msg))
    rescue
      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "Something went wrong..."})
    end
  end

end
