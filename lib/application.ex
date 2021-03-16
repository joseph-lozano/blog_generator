defmodule Blog.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Blog.Server, options: [port: 4000]},
      {Blog.Watcher, []}
    ]

    opts = [strategy: :one_for_one, name: Blog.Supervisor]

    Logger.info("Starting application at http://localhost:4000")

    Supervisor.start_link(children, opts)
  end
end
