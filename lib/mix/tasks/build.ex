defmodule Mix.Tasks.BlogGenerator.Build do
  use Mix.Task
  import EExHTML

  def run(_) do
    IO.puts("Hello World!")

    content = ~E"<h1>Hello World</h1>"
    File.mkdir("./_site")
    File.write!("./_site/index.html", to_string(content), [:write, :ut8])
  end
end
