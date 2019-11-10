defmodule Sec.RSA do
  # use GenServer
  @opts []
  @pem File.read!("priv/pk.pem")
  @sk File.read!("priv/sk.pem") |> :public_key.pem_decode()
                                |> Enum.at(0)
                                |> :public_key.pem_entry_decode()

  def enc(plaintext, pk) do
    pk = pem_decode!(pk)
    :public_key.encrypt_public(plaintext, pk, @opts)
  end

  def dec(ciphertext) do
    :public_key.decrypt_private(ciphertext, @sk, @opts)
  end

  def pem(), do: @pem

  def pem_decode!(pem) do
    pem
      |> :public_key.pem_decode()
      |> Enum.at(0)
      |> :public_key.pem_entry_decode()
  end
end
