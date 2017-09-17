defmodule Hypervisor.Docker.Client do
  alias Hypervisor.Docker.HTTP
  @moduledoc """
  Docker client
  """
  @version "v1.29"
  @uri "http+unix://#{URI.encode_www_form("/var/run/docker.sock")}"

  @doc """
  Fetch all running containers
  """
  def all do
    HTTP.get(@uri, "/#{@version}/containers/json")
  end

  @doc """
  Inspect container with `id` or name
  """
  def get(id) do
    HTTP.get(@uri, "/#{@version}/containers/#{id}/json")
  end

  @doc """
  Get runtime statistics from container with `id` or `name`
  """
  def stats(id, opts \\ []) do
    HTTP.get(@uri, "/#{@version}/containers/#{id}/stats", opts)
  end

  @doc """
  Accepts a containerId and a keyword list of options.
  see https://docs.docker.com/engine/api/v1.29/#operation/ContainerLogs
  Returns a list of log entries
  """
  def logs(id, opts \\ []) do
    @uri
    |> HTTP.get("/#{@version}/containers/#{id}/logs", opts)
    |> String.split("\n")
    |> Enum.map(&(extract_payload(&1)))
  end

  defp extract_payload(
    << _stream_type :: size(8), _padding :: size(24), _size :: size(32), payload :: bitstring >>
  ), do: payload
  defp extract_payload(_), do: []
end
