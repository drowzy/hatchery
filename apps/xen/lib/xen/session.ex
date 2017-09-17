defmodule Xen.Session do
  @default_url "http+unix://#{URI.encode_www_form("/var/xapi/xapi")}"

  defstruct url: nil,
    username: nil,
    password: nil,
    status: :disconnected,
    session_id: nil

  @type t :: %__MODULE__{
    url: String.t,
    username: String.t,
    password: String.t,
    session_id: term,
    status: :connected | :connecting | :disconnected
  }

  def new(config \\ []) do
    url = Keyword.get(config, :url,  @default_url)
    username = Keyword.get(config, :username,  "")
    password = Keyword.get(config, :password,  "")

    %__MODULE__{
      url: url,
      username: username,
      password: password,
      status: :disconnected
    }
  end
end
