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

  def init({request, interval}) do
    state =
      %State{
        request: request,
        interval: interval
      }

    {:ok, state, {:continue, :request}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info(:request, state) do
    {:noreply, state, {:continue, :request}}
  end

  def handle_continue(:request, %State{interval: interval, attempts: attempts} = state) do
    do_request(state)

    Process.send_after(self(), :request, interval)

    {:noreply, %State{state | attempts: attempts + 1}}
  end

  defp do_request(%State{request: fun}) when is_function(fun) do
    fun.()
  end

  defp do_request(%State{request: {m, f, a}}) do
    :erlang.apply(m, f, a)
  end
end
