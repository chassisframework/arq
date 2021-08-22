defmodule ARQTest do
  use ExUnit.Case
  doctest ARQ

  describe "start/2" do
    test "with a fun" do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} = ARQ.start(fn -> send(me, {self(), msg}) end)
      ARQ.stop(pid)

      assert_receive({^pid, ^msg})
    end

    test "with an mfa" do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} = ARQ.start({__MODULE__, :request, [me, msg]})
      ARQ.stop(pid)

      assert_receive({^pid, ^msg})
    end

    test "re-sends messages until told to stop" do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} = ARQ.start(fn -> send(me, {self(), msg}) end, interval: 100)

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

    test "stops when fun returns `:stop`" do
      msg = :crypto.strong_rand_bytes(10)
      me = self()

      {:ok, pid} =
        ARQ.start(fn ->
          send(me, {self(), msg})
          :stop
        end, interval: 1)

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
