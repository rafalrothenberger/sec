defmodule SecWeb.Protocols.GjssController do
  use SecWeb, :controller


  def verify(conn, %{"payload" => %{"sigma" => %{"z" => z, "c" => c, "r" => r, "s" => s}, "msg" => msg, "A" => bigA}}) do
    conn
    |> json(Sec.Protocol.GJSS.verify(%{z: z, c: c, r: r, s: s}, msg, bigA))
  end

  def sign(conn, %{"msg" => msg, "a" => a}) do
    try do
      conn
      |> json(Sec.Protocol.GJSS.sign(a, msg))
    rescue
      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "Something went wrong..."})
    end
  end

end
