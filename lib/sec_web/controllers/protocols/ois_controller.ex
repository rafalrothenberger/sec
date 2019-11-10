defmodule SecWeb.Protocols.OisController do
  use SecWeb, :controller
  use Overridable

  def init(conn, %{"payload" => %{"A" => bigA, "X" => bigX}}) do
    conn
    |> json(Sec.Protocol.OIS.init(bigA, bigX))
  end

  def verify(conn, %{"session_token" => token, "payload" => %{"s1" => s1, "s2" => s2}}) do
    code = #try do
      Sec.Protocol.OIS.verify(token, s1, s2)
    # rescue
    #   _ -> 403
    # end
    conn
    |> put_status(code)
    |> json(%{verified: code == 200})
  end

  def random(conn, _param) do
    conn
    |> json(Sec.Protocol.OIS.random())
  end

  def client(conn, %{"a1" => a1, "a2" => a2, "x1" => x1, "x2" => x2, "c" => c}) do
    {code, payload} = try do
      {
        200, Sec.Protocol.OIS.client(a1, a2, x1, x2, c)
      }
    rescue
      _ -> {500, %{error: "Something went wrong..."}}
    end

    conn
    |> put_status(code)
    |> json(payload)
  end

end
