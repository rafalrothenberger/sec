defmodule SecWeb.Protocols.SisController do
  use SecWeb, :controller
  use Overridable

  def init(conn, %{"payload" => %{"A" => bigA, "X" => bigX}}) do
    conn
    |> json(Sec.Protocol.SIS.init(bigA, bigX))
  end

  def verify(conn, %{"session_token" => token, "payload" => %{"s" => s}}) do
    code = try do
      Sec.Protocol.SIS.verify(token, String.to_integer(s))
    rescue
      _ -> 403
    end
    conn
    |> put_status(code)
    |> json(%{verified: code == 200})
  end

  def random(conn, _param) do
    conn |> json(Sec.Protocol.SIS.random())
  end

  def client(conn, %{"a" => a, "x" => x, "c" => c}) do
    {code, payload} =
      # try do
      {
        200,
        Sec.Protocol.SIS.client(a, x, c)
      }
    # rescue
    #   _ -> {500, %{error: "Something went wrong..."}}
    # end

    conn
    |> put_status(code)
    |> json(payload)
  end

end
