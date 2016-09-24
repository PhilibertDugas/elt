defmodule Elt.PageControllerTest do
  use Elt.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Elt"
  end
end
