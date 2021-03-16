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
    {:ok, pid} = FileSystem.start_link(dirs: ["site/"])
    FileSystem.subscribe(pid)
    {:noreply, pid}
  end

  def handle_info({:file_event, _, {file, _}}, state) do
    cond do
      String.ends_with?(file, "post.html.eex") -> Blog.make_posts()
      String.ends_with?(file, "index.html.eex") -> Blog.make_index()
      true -> Blog.make_post(file)
    end

    {:noreply, state}
  end
end
