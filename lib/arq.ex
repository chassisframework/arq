defmodule ARQ do
  @moduledoc """
  Dead simple [Automatic Request Repeat](https://en.wikipedia.org/wiki/Automatic_repeat_request) implementation for independent messages.

  Local party sends messages by providing an mfa or a fun/0 to ARQ.start/2.

  If mfa or fun returns `:stop`, the ARQ process will terminate. This is useful for synchronous responses.

  Upon receipt of an asynchronous message, remote party can acknowledge the message (and stop its repeat) by calling ARQ.stop/1 or sending `:stop` to the requestor process.
  """

  alias ARQ.Request

  use DynamicSupervisor

  @default_interval 1_000

  @type request :: mfa() | fun()
  @type opt :: {:interval, pos_integer()}
  @type opts :: [opt]

  @doc """
  Starts an ARQ process with the given mfa or fun/0.

  You can provide the following options:
    - :interval - number of milliseconds between function invocation repeat.
  """
  @spec start(request(), Supervisor.supervisor(), opts()) :: {:ok, pid()}
  def start(request, supervisor, opts \\ []) when (is_function(request, 0) or is_tuple(request)) and is_list(opts) do
    interval = Keyword.get(opts, :interval, @default_interval)

    DynamicSupervisor.start_child(supervisor, {Request, {request, interval}})
  end

  @doc """
  Stops the given ARQ process.
  """
  @spec stop(GenServer.server()) :: any()
  defdelegate stop(requester), to: Request

  @doc false
  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args)
  end

  @doc false
  @impl DynamicSupervisor
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
