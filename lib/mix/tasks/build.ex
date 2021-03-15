defmodule Mix.Tasks.Blog.Build do
  @moduledoc false

  use Mix.Task

  def run(_args) do
    Blog.make()
  end
end
