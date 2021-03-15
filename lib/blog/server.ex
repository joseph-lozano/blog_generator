defmodule Blog.Server do
  @moduledoc """
  Server _site for development purposes
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @files File.ls!("_site")

  get "/" do
    send_file(conn, "index.html")
  end

  get("/styles.css") do
    send_file(conn, "styles.css")
  end

  get "/:slug" do
    file_name = "#{slug}.html"

    if file_name in @files do
      send_file(conn, file_name)
    else
      send_resp(conn, 404, "not found")
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp send_file(conn, file) do
    send_resp(conn, 200, File.read!("_site/#{file}"))
  end
end
