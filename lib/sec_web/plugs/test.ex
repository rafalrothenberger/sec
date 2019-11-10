defmodule SecWeb.Plugs.Test do
  import Plug
  require Logger

  def init(default) do
   Logger.debug("#{inspect default}")
  end

  # def call(%Plug.Conn{params: params, body_params: body_params, request_path: "/plug/test", path_info: path_info, method: method} = conn, _default) do
  #   Logger.debug("Body params: #{inspect body_params}")
  #   Logger.debug("Path info: #{inspect path_info}")
  #   Logger.debug("Method: #{inspect method}")
  #   %{conn | params: %{c: "123"}, body_params: %{c: "123"}, request_path: "/protocols", path_info: ["protocols"], method: "GET"}
  # end

  def call(%Plug.Conn{resp_body: body} = conn, _default) do
    Logger.debug("Body: #{inspect body}")
    conn
  end

end
