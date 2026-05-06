defmodule CrudAppWeb.PageController do
  use CrudAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
