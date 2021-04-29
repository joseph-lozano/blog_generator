defmodule Blog do
  @moduledoc """
  Top level Blog Context
  """
  alias Blog.Post

  @source_dir "site"
  @dest_dir "_site"

  def make() do
    Application.ensure_all_started(:makeup_elixir)

    make_directory()

    copy_static()

    make_posts()

    make_index()
  end

  defp make_directory() do
    File.mkdir(@dest_dir)
  end

  defp copy_static() do
    copy_css()
    copy_file("resume.pdf")
    copy_file("keybase.txt")
    copy_file("favicon.ico")
    copy_file("E8A63D71.asc")
    copy_markdown()
  end

  def copy_markdown() do
    Path.wildcard("#{@source_dir}/*.md")
    |> Enum.each(fn file ->
      [yaml, md] = file |> File.read!() |> String.split("---", parts: 2, trim: true)
      attrs = YamlElixir.read_from_string!(yaml)

      inner_content =
        md
        |> Earmark.as_html!()
        |> Blog.Highlighter.highlight()

      %{"title" => title, "slug" => slug} = attrs

      content =
        EEx.eval_file("#{@source_dir}/post.html.eex",
          post: %{title: title, description: nil, date: nil, draft: false},
          inner_content: inner_content,
          render: &EEx.eval_file/2
        )

      File.write("#{@dest_dir}/#{slug}.html", content, [:write])
    end)
  end

  defp copy_css() do
    File.cp!("#{@source_dir}/styles/monokai.css", "#{@dest_dir}/monokai.css")
  end

  defp copy_file(file) do
    File.cp!(Path.join([@source_dir, file]), Path.join([@dest_dir, file]))
  end

  def make_post(file_path) do
    file_path
    |> get_post()
    |> save_post()
  end

  def make_posts() do
    get_posts()
    |> check_for_errors()
    |> save_posts()
  end

  def get_post(path) do
    [year, month, day, slug] =
      path
      |> Path.basename()
      |> Path.rootname()
      |> String.split("-", parts: 4)

    path
    |> File.read!()
    |> Post.parse(date(year, month, day), slug)
  end

  def get_posts() do
    "#{@source_dir}/posts/*.md"
    |> Path.wildcard()
    |> Enum.map(&get_post/1)
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

  defp save_post(%Blog.Post{} = post) do
    inner_content =
      post.content
      |> Earmark.as_html!()
      |> Blog.Highlighter.highlight()

    content =
      EEx.eval_file("#{@source_dir}/post.html.eex",
        post: post,
        inner_content: inner_content,
        render: &EEx.eval_file/2
      )

    File.write("#{@dest_dir}/#{post.slug}.html", content, [:write])

    post
  end

  defp save_posts(posts) do
    Enum.map(posts, &save_post/1)
  end

  def make_index() do
    posts =
      get_posts()
      |> Enum.sort_by(& &1.date, {:desc, Date})
      |> Enum.filter(&show_draft?/1)

    content =
      EEx.eval_file("#{@source_dir}/index.html.eex",
        posts: posts,
        render: &EEx.eval_file/2
      )

    File.write("#{@dest_dir}/index.html", content, [:write])
  end

  @spec date(String.t(), String.t(), String.t()) :: Date.t()
  defp date(year, month, day) do
    Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day))
  end

  defp show_draft?(%Post{draft: draft}) do
    published? = !draft
    prod? = Mix.env() == :prod

    published? or not prod?
  end
end
