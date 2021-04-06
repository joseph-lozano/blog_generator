if Mix.env() != :prod do
  defmodule Blog.Watcher do
    @moduledoc """
    Refresh files when they change
    """
    use GenServer

    def start_link(_) do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def init(_) do
      {:ok, [], {:continue, :subscribe}}
    end

    def handle_continue(:subscribe, _state) do
      {:ok, pid} = FileSystem.start_link(dirs: ["site/", "lib/"])
      FileSystem.subscribe(pid)
      {:noreply, pid}
    end

    def handle_info({:file_event, _, {_file, _}}, state) do
      Blog.make()

      {:noreply, state}
    end
  end
end
