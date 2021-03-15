defmodule Mix.Tasks.Blog.Build do
  use Mix.Task

  alias Blog.Post

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
    "#{@source_dir}/posts"
    |> File.ls!()
    |> Enum.map(fn post ->
      [year, month, day, slug] = post |> Path.rootname() |> String.split("-", parts: 4)

      "#{@source_dir}/posts/#{post}"
      |> File.read!()
      |> Post.parse(date(year, month, day), slug)
    end)
  end

  def raise_if_duplicates(posts) do
    post_slugs = Enum.map(posts, & &1.slug)

    if length(post_slugs) == length(Enum.uniq(post_slugs)) do
      posts
    else
      raise "Duplicate filenames detected. Aborting."
      System.halt(1)
    end
  end

  defp save_posts(posts) do
    Enum.map(posts, fn post ->
      inner_content = Earmark.as_html!(post.content)

      content = EEx.eval_file("#{@source_dir}/post.html.eex", inner_content: inner_content)
      File.write("#{@dest_dir}/#{post.slug}.html", content, [:write, :utf8])

      post
    end)
  end

  defp make_index(posts) do
    content = EEx.eval_file("#{@source_dir}/index.html.eex", posts: posts)
    File.write("#{@dest_dir}/index.html", content, [:write, :utf8])
  end

  @spec date(String.t(), String.t(), String.t()) :: Date.t()
  defp date(year, month, day) do
    Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day))
  end
end
