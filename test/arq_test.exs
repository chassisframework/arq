defmodule ARQTest do
  use ExUnit.Case
  doctest ARQ

  setup_all do
    {:ok, supervisor} = ARQ.start_link()

    [supervisor: supervisor]
  end

  describe "start/2" do
    test "with a fun", %{supervisor: supervisor} do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} = ARQ.start(fn -> send(me, {self(), msg}) end, supervisor)
      ARQ.stop(pid)

      assert_receive({^pid, ^msg})
    end

    test "with an mfa", %{supervisor: supervisor} do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} = ARQ.start({__MODULE__, :request, [me, msg]}, supervisor)
      ARQ.stop(pid)

      assert_receive({^pid, ^msg})
    end

    test "re-sends messages until told to stop", %{supervisor: supervisor} do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} = ARQ.start(fn -> send(me, {self(), msg}) end, supervisor, interval: 100)

      Process.sleep(400)

      assert_receive({^pid, ^msg})
      assert_receive({^pid, ^msg})
      assert_receive({^pid, ^msg})

      ARQ.stop(pid)
      flush()

      Process.sleep(200)

      refute_receive({^pid, ^msg})

      refute Process.alive?(pid)
    end

    test "stops when fun returns `:stop`", %{supervisor: supervisor} do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} =
        ARQ.start(fn ->
          send(me, {self(), msg})
          :stop
        end, supervisor, interval: 1)

      refute Process.alive?(pid)

      assert_receive({^pid, ^msg})
      refute_receive({^pid, ^msg})
    end
  end

  def request(pid, msg) do
    send(pid, {self(), msg})
  end

  def flush do
    receive do
	    _ ->
		    flush()

    after
      0  -> :ok
    end
  end
end
