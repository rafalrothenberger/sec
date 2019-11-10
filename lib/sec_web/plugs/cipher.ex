defmodule SecWeb.Plugs.Cipher do
  import Plug.Conn
  require Logger

  def init(module) do
    module
  end

  def call(%Plug.Conn{path_info: ["salsa", "client" | rest]} = conn, _) do
    %{conn | path_info: rest}
  end

  def call(%Plug.Conn{params: %{"ciphertext" => ciphertext, "nonce" => nonce} = params, path_info: ["salsa" | rest]} = conn, _) do
    ciphertext = Base.decode64!(ciphertext)
    nonce = Base.decode64!(nonce)

    Logger.debug("Org: #{inspect params}")
    params = Sec.Cipher.XSalsa.dec(ciphertext, nonce) |> Jason.decode!()
    Logger.debug("Dec: #{inspect params}")

    %{conn | params: params, path_info: rest} |> register_before_send(fn conn ->
      encrypt_response_salsa(conn)
    end)
  end

  def call(%Plug.Conn{path_info: ["salsa" | rest]} = conn, _) do
    %{conn | path_info: rest} |> register_before_send(fn conn ->
      encrypt_response_salsa(conn)
    end)
  end

  def call(conn, _), do: conn

  defp encrypt_response_salsa(%Plug.Conn{status: 500} = conn) do
    conn
  end

  defp encrypt_response_salsa(%Plug.Conn{resp_body: body} = conn) do
    plaintext = IO.iodata_to_binary(body)
    {ciphertext, nonce} = Sec.Cipher.XSalsa.enc(plaintext)
    body = %{ciphertext: Base.encode64(ciphertext), nonce: Base.encode64(nonce)} |> Jason.encode!()
    %{conn | resp_body: body}
  end
end
