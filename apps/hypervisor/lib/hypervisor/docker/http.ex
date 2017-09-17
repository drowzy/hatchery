defmodule Hypervisor.Docker.HTTP do
  @moduledoc """
  Http Helper for docker api
  """
  require Logger

  defp default_headers do
    {:ok , hostname} = :inet.gethostname
    %{"Content-Type" => "application/json", "Host" => hostname}
  end

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(uri, resource, opt \\ []) do
    base_url = uri <> resource
    base_url
    |> HTTPoison.get!(default_headers(), params: opt)
    |> decode_body
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(uri, resource, data \\ "", opt \\ []) do
    data = Poison.encode! data
    base_url = uri <> resource

    base_url
    |> HTTPoison.post!(data, default_headers(), params: opt)
    |> decode_body
  end

  defp decode_body(%HTTPoison.Response{body: ""}), do: :nil
  defp decode_body(%HTTPoison.Response{body: body}) do
    case Poison.decode(body) do
      {:ok, map} -> normalize(map)
      {:error, _} -> body
    end
  end

  defp normalize(body) when is_list(body), do: Enum.map(body, &normalize/1)
  defp normalize(body) do
    for {key, val} <- body,
      into: %{},
      do: {Macro.underscore(key), val}
  end
end
