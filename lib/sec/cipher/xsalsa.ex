defmodule Sec.Cipher.XSalsa do
  alias Salty.Secretbox.Xsalsa20poly1305, as: Cipher

  @key File.read!("priv/salsa/key.bin")

  def enc(plaintext) do
    nonce = :crypto.strong_rand_bytes(Cipher.noncebytes())
    {:ok, ciphertext} = Cipher.seal(plaintext, nonce, @key)
    {ciphertext, nonce}
  end

  def dec(ciphertext, nonce) do
    dec({ciphertext, nonce})
  end

  def dec({ciphertext, nonce}) do
    {:ok, plaintext} = Cipher.open(ciphertext, nonce, @key)
    plaintext
  end
end
