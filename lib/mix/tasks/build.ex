defmodule Mix.Tasks.Blog.Build do
  use Mix.Task

  @spec run(any) :: any()
  def run(_args) do
    Mix.shell().info("Generating Static Files to ./site")

    content = EEx.eval_file("site/index.html.eex", name: "File")

    {:ok, posts} = File.ls("site/posts")

    File.mkdir("./_site")
    File.write("./_site/index.html", content, [:write, :utf8])

    Enum.each(posts, fn post ->
      title = Path.rootname(post)
      inner_content = Earmark.as_html!(File.read!("site/posts/#{post}"))

      content = EEx.eval_file("site/post.html.eex", inner_content: inner_content)

      Mix.shell().info("Writing #{title}")
      File.write("./_site/#{title}.html", content, [:write, :utf8])
    end)

    Mix.shell().info("Done")
  end
end
