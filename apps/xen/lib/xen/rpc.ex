defmodule Xen.Rpc do
  def connect(config \\ []) do
    session = Xen.Session.new(config)

    req_body = encode("session.login_with_password", [session.username, session.password])

    case request(session.url, req_body) do
      {:ok, resp} ->
        session_id = Map.get(resp, "Value")
        {:ok, %{session | session_id: session_id, status: :connected }}
      {:error, reason} -> {:error, reason}
    end
  end

  def disconnect(%Xen.Session{session_id: session_id, url: url} = session) do
    req_body = encode("session.logout", [session_id])

    case request(url, req_body) do
      {:ok, _} -> {:ok, %{session | session_id: nil, status: :disconnected}}
      {:error, reason} -> {:error, reason}
    end
  end

  def import(%Xen.Session{session_id: session_id, url: url}, file_path) do

  end

  def call(%Xen.Session{session_id: session_id, url: url}, method_name, params \\ []) do
    req_body = encode(method_name, [session_id] ++ params)

    request(url, req_body)
  end

  defp request(url, req_body) do
    case HTTPoison.post(url, req_body) do
      {:ok, body} -> decode_body(body)
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
    end
  end

  defp decode_body(%HTTPoison.Response{body: body}) do
    %XMLRPC.MethodResponse{param: param} = XMLRPC.decode!(body)

    case param do
      %{"Status" => "Success"} -> {:ok, param}
      _ -> {:error, param}
    end
  end

  defp encode(method_name, params) do
    %XMLRPC.MethodCall{
      method_name: method_name,
      params: params
    } |> XMLRPC.encode!
  end
end
