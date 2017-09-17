defmodule Xen do
  use GenServer
  alias Xen.Session

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  # Client API
  def init(config \\ []) do
    {:ok, session} = Xen.Rpc.connect(config)
    {:ok, session}
  end

  def call(pid, method_name, params),
    do: GenServer.call(pid, {:call, method_name, params})

  def connect(pid), do: GenServer.call(pid, :connect)

  def disconnect(pid), do: GenServer.cast(pid, :disconnect)

  # Server API
  def handle_call(:connect, _from, %Session{status: :connected} = state), do: {:reply, state, state}
  def handle_call(:connect, _from, %Session{} = state) do
    res = {_, new_state} = Xen.Rpc.connect(state)

    {:reply, res, new_state}
  end

  def handle_call({:call, method_name, params}, _from, state) do
    res = Xen.Rpc.call(state, method_name, params)

    {:reply, res, state}
  end

  def handle_cast(:disconnect, _from, %Session{status: :disconnected} = state),
    do: {:noreply, state}
  def handle_cast(:disconnect, _from, %Session{} = state) do
    {_, new_state} = Xen.Rpc.disconnect(state)

    {:noreply, new_state}
  end

end
