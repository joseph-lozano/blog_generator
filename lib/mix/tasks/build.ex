defmodule Mix.Tasks.Blog.Build do
  use Mix.Task

  @source_dir "site"
  @dest_dir "_site"

  @spec run(any) :: any()
  def run(_args) do
    make_directory()

    posts = make_posts()

    make_index(posts)
  end

  defp make_directory() do
    File.mkdir(@dest_dir)
  end

  defp make_posts() do
    get_posts()
    |> raise_if_duplicates()
    |> save_posts()
  end

  def get_posts() do
    File.ls!("#{@source_dir}/posts")
  end

  def raise_if_duplicates(posts) do
    if length(posts) == length(Enum.uniq(posts)) do
      posts
    else
      raise "Duplicate filenames detected. Aborting."
      System.halt(1)
    end
  end

  defp save_posts(posts) do
    Enum.map(posts, fn post ->
      title = Path.rootname(post)
      inner_content = Earmark.as_html!(File.read!("#{@source_dir}/posts/#{post}"))

      content = EEx.eval_file("#{@source_dir}/post.html.eex", inner_content: inner_content)
      File.write("#{@dest_dir}/#{title}.html", content, [:write, :utf8])

      title
    end)
  end

  defp make_index(posts) do
    content = EEx.eval_file("#{@source_dir}/index.html.eex", posts: posts)
    File.write("#{@dest_dir}/index.html", content, [:write, :utf8])
  end
end
