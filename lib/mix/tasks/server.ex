defmodule Mix.Tasks.Blog.Server do
  @moduledoc false

  use Mix.Task

  @spec run(any) :: any
  def run(args) do
    Application.ensure_all_started(:blog)
    Mix.Tasks.Run.run(["--no-halt"] ++ args)
  end
end
