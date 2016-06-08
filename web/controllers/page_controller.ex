defmodule GithubStatus.PageController do
  use GithubStatus.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
