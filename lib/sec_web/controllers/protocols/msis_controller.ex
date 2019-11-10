defmodule SecWeb.Protocols.MsisController do
  use SecWeb, :controller
  use Overridable

  def init(conn, %{"payload" => %{"A" => bigA, "X" => bigX}}) do
    conn
    |> json(Sec.Protocol.MSIS.init(bigA, bigX))
  end

  def verify(conn, %{"session_token" => token, "payload" => %{"S" => bigS}}) do
    code = #try do
      Sec.Protocol.MSIS.verify(token, bigS)
    # rescue
    #   _ -> 403
    # end
    conn
    |> put_status(code)
    |> json(%{verified: code == 200})
  end

  def random(conn, _param) do
    try do
      conn |> json(Sec.Protocol.MSIS.random())
    rescue
      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "Something went wrong..."})
    end
  end

  def client(conn, %{"a" => a, "x" => x, "c" => c}) do
    {code, payload} = try do
      {
        200,
        Sec.Protocol.MSIS.client(a, x, c)
      }
    rescue
      _ -> {500, %{error: "Something went wrong..."}}
    end

    conn
    |> put_status(code)
    |> json(payload)
  end

end
