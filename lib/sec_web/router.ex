defmodule SecWeb.Router do
  use SecWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/protocols", SecWeb do
    get "/", ProtocolsController, :list

    scope "/sis", Protocols do
      post "/init", SisController, :init
      post "/verify", SisController, :verify
      get "/random", SisController, :random
      post "/client", SisController, :client
    end

    scope "/sss", Protocols do
      post "/client", SssController, :client
      post "/verify", SssController, :verify
    end

    scope "/ois", Protocols do
      post "/init", OisController, :init
      post "/verify", OisController, :verify
      get "/random", OisController, :random
      post "/client", OisController, :client
    end

    scope "/msis", Protocols do
      post "/init", MsisController, :init
      post "/verify", MsisController, :verify
      get "/random", MsisController, :random
      post "/client", MsisController, :client
    end

    scope "/blsss", Protocols do
      post "/client", BlsssController, :sign
      post "/verify", BlsssController, :verify
    end

    scope "/gjss", Protocols do
      post "/client", GjssController, :sign
      post "/verify", GjssController, :verify
    end

    scope "/naxos", Protocols do
      post "/rand", NaxosController, :rand
      post "/exchange", NaxosController, :exchange
      post "/client", NaxosController, :client
      get "/pkey", NaxosController, :pkey
    end
  end

  scope "/dec", SecWeb do
    post "/salsa", BasicController, :salsa
  end

  scope "/enc", SecWeb do
    post "/salsa", BasicController, :salsa_enc
  end
end
