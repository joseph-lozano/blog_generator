defmodule Blog.Server do
  @moduledoc """
  Server _site for development purposes
  """
  import Plug.Conn

  use Plug.Builder

  plug(Plug.Static,
    at: "/",
    from: "_site"
  )

  plug(:not_found)

  def not_found(conn, _) do
    send_resp(conn, 404, "not found")
  end
end
