defmodule TotpGeneratorWeb.PageController do
  use TotpGeneratorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
