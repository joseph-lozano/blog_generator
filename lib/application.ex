defmodule Blog.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Blog.Server, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: Blog.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
end
