defmodule SecWeb.BasicController do
  use SecWeb, :controller

  def test(conn, params) do
    require Logger
    Logger.debug("#{inspect params}")
    conn |> json(%{error: []})
  end

  def salsa(conn, %{"ciphertext" => ciphertext, "nonce" => nonce}) do
    plaintext = Sec.Cipher.XSalsa.dec(ciphertext |> Base.decode64!(), nonce |> Base.decode64!())
    json(conn, Jason.decode!(plaintext))
  end

  def salsa_enc(conn, params) do
    params = Map.delete(params, "ciphertext") |> Map.delete("nonce")
    {ciphertext, nonce} = Sec.Cipher.XSalsa.enc(Jason.encode!(params))
    body = %{ciphertext: ciphertext |> Base.encode64(), nonce: nonce |> Base.encode64()}
    json(conn, body)
  end
end
