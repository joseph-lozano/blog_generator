defmodule Mix.Tasks.Blog.Build do
  use Mix.Task
  import EExHTML

  def run(args \\ ["World"]) do
    name = Enum.join(args, " ")
    content = ~E"<h1>Hello <%= name %></h1>"
    File.mkdir("./_site")
    File.write!("./_site/index.html", to_string(content), [:write, :ut8])
  end
end
