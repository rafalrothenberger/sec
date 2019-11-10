defmodule SecWeb.ProtocolsController do
  use SecWeb, :controller
  def list(conn, _params) do
    conn |> json(%{schemas: ["sis", "ois", "sss", "msis", "blsss", "gjss", "naxos"]})
  end

end
