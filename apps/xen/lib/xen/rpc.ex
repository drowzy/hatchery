defmodule Xen.Rpc do
  def connect(%Xen.XAPI{url: url, username: username, password: password}) do
    req_body = %XMLRPC.MethodCall{
      method_name: "session.login_with_password",
      params: [username, password]
    } |> XMLRPC.encode!

    case HTTPoison.post(url, req_body) do
      {:ok, %HTTPoison.Response{body: body}} -> {:ok, decode(body)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp decode(body), do: XMLRPC.decode!(body)
end
