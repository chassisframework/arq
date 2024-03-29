defmodule ARQ.Request do
  use GenServer, restart: :transient

  defmodule State do
    defstruct [
      :request,
      :interval,
      attempts: 0
    ]
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def stop(requester) do
    GenServer.call(requester, :stop)
  end

  @impl GenServer
  def init({request, interval}) do
    state =
      %State{
        request: request,
        interval: interval
      }

    {:ok, state, {:continue, :request}}
  end

  @impl GenServer
  def handle_info(:request, state) do
    {:noreply, state, {:continue, :request}}
  end

  @impl GenServer
  def handle_continue(:request, %State{interval: interval, attempts: attempts} = state) do
    case do_request(state) do
      :stop ->
        {:stop, :normal, state}

      _ ->
        Process.send_after(self(), :request, interval)

        {:noreply, %State{state | attempts: attempts + 1}}
    end
  end

  @impl GenServer
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  defp do_request(%State{request: fun}) when is_function(fun) do
    fun.()
  end

  defp do_request(%State{request: {m, f, a}}) do
    :erlang.apply(m, f, a)
  end
end
