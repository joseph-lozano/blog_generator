defmodule Blog.Server do
  @moduledoc """
  Server _site for development purposes
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_file(conn, "index.html")
  end

  get("/styles.css") do
    send_file(conn, "styles.css")
  end

  get("/resume.pdf") do
    send_file(conn, "resume.pdf")
  end

  get "/:slug" do
    file = "_site/#{slug}.html"

    if File.exists?(file) do
      send_file(conn, 200, file)
    else
      send_resp(conn, 404, "not found")
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def send_file(conn, file) do
    send_file(conn, 200, "_site/#{file}")
  end
end
