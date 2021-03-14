defmodule Mix.Tasks.Blog.Build do
  use Mix.Task
  import EExHTML

  def run(_args) do
    Mix.shell().info("Generating Static Files to ./site")
    name = "Blog Generator"
    content = ~E"<h1>Hello <%= name %></h1>"
    File.mkdir("./_site")
    File.write("./_site/index.html", to_string(content), [:write, :ut8])
    Mix.shell().info("Done Generating Static Files")
  end
end
