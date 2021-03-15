defmodule Blog do
  @moduledoc """
  Top level Blog Context
  """
  alias Blog.Post

  @source_dir "site"
  @dest_dir "_site"

  def make() do
    make_directory()

    copy_resume()

    posts = make_posts()

    make_index(posts)
  end

  defp make_directory() do
    File.mkdir(@dest_dir)
  end

  defp copy_resume() do
    File.cp!("#{@source_dir}/resume.pdf", "#{@dest_dir}/resume.pdf")
  end

  defp make_posts() do
    get_posts()
    |> check_for_errors()
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

  defp check_for_errors(posts) do
    posts
    |> raise_if_duplicates()
    |> raise_if_index()
    |> raise_if_blank()
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

  defp raise_if_index(posts) do
    Enum.map(posts, fn post ->
      if post.slug == "index" do
        raise "'index' is not a valid slug"
        System.halt(1)
      else
        post
      end
    end)
  end

  defp raise_if_blank(posts) do
    Enum.map(posts, fn post ->
      if post.slug == "" do
        raise "slug cannot be blank"
        System.halt(1)
      else
        post
      end
    end)
  end

  defp save_posts(posts) do
    Enum.map(posts, fn post ->
      inner_content = Earmark.as_html!(post.content)

      content =
        EEx.eval_file("#{@source_dir}/post.html.eex", post: post, inner_content: inner_content)

      File.write("#{@dest_dir}/#{post.slug}.html", content, [:write])

      post
    end)
  end

  defp make_index(posts) do
    content = EEx.eval_file("#{@source_dir}/index.html.eex", posts: posts)
    File.write("#{@dest_dir}/index.html", content, [:write])
  end

  @spec date(String.t(), String.t(), String.t()) :: Date.t()
  defp date(year, month, day) do
    Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day))
  end
end
