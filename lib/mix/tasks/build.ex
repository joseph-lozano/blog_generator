defmodule Mix.Tasks.Blog.Build do
  use Mix.Task

  @spec run(any) :: any()
  def run(_args) do
    Mix.shell().info("Generating Static Files to ./site")

    {:ok, posts} = File.ls("site/posts")

    File.mkdir("./_site")

    posts =
      Enum.map(posts, fn post ->
        title = Path.rootname(post)
        inner_content = Earmark.as_html!(File.read!("site/posts/#{post}"))

        Mix.shell().info("Writing #{title}.html")

        content = EEx.eval_file("site/post.html.eex", inner_content: inner_content)
        File.write("./_site/#{title}.html", content, [:write, :utf8])

        title
      end)

    Mix.shell().info("Writing index.html")

    content = EEx.eval_file("site/index.html.eex", posts: posts)
    File.write("./_site/index.html", content, [:write, :utf8])

    Mix.shell().info("Done")
  end
end
