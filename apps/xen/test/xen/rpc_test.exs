defmodule Xen.RpcTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  @conn_success ~s(<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>Status</name><value>Success</value></member><member><name>Value</name><value>OpaqueRef:cdf4babd-fcba-828f-ca28-408774e0e2d5</value></member></struct></value></param></params></methodResponse>)
  @conn_failure ~s(<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>Status</name><value>Failure</value></member></struct></value></param></params></methodResponse>)

  test "client returns a session struct when connect is successfull", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/", fn conn ->
      Plug.Conn.resp(conn, 200, @conn_success)
    end

    {:ok, %Xen.XAPI{status: status}} = Xen.Rpc.connect(url: endpoint_url(bypass.port), username: "test", password: "test")
    assert status == :connected
  end

  test "client returns an error when the request is not success", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/", fn conn ->
      Plug.Conn.resp(conn, 200, @conn_failure)
    end

    assert {:error, _} = Xen.Rpc.connect(url: endpoint_url(bypass.port), username: "test", password: "test")
  end

  test "disconnect sets the status to disconnected", %{bypass: bypass} do
    Bypass.expect_once bypass, "POST", "/", fn conn ->
      Plug.Conn.resp(conn, 200, @conn_success)
    end

    session = %Xen.XAPI{url: endpoint_url(bypass.port), status: :connected}

    assert {:ok, %Xen.XAPI{status: :disconnected}} = Xen.Rpc.disconnect(session)
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end