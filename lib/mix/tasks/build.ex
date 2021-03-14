defmodule Mix.Tasks.Blog.Build do
  use Mix.Task
  import EExHTML

  @spec run(any) :: any()
  def run(_args) do
    Mix.shell().info("Generating Static Files to ./site")

    name = "World"
    content = ~E"<h1>Hello <%= name %></h1>"
    html = to_string(content)

    File.mkdir("./_site")
    File.write("./_site/index.html", html, [:write, :utf8])

    Mix.shell().info("Done")
  end
end
