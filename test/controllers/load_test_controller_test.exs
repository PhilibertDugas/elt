defmodule Elt.LoadTestControllerTest do
  use Elt.ConnCase

  alias Elt.LoadTest
  {:ok, plan} = File.read("elt-test.json")
  @valid_attrs %{plan: plan}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, load_test_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing load tests"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, load_test_path(conn, :new)
    assert html_response(conn, 200) =~ "New load test"
  end

  test "launches load test and redirects to progress", %{conn: conn} do
    conn = post conn, load_test_path(conn, :create), load_test: @valid_attrs
    assert redirected_to(conn) == load_test_path(conn, :progress, "1")
    task = Map.Bucket.get("1")
    assert Process.alive?(task)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, load_test_path(conn, :create), load_test: @invalid_attrs
    assert html_response(conn, 400) =~ "Error, wrong parameters"
  end

  test "shows chosen resource", %{conn: conn} do
    load_test = Repo.insert! %LoadTest{}
    conn = get conn, load_test_path(conn, :show, load_test)
    assert html_response(conn, 200) =~ "Show load test"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, load_test_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    load_test = Repo.insert! %LoadTest{}
    conn = get conn, load_test_path(conn, :edit, load_test)
    assert html_response(conn, 200) =~ "Edit load test"
  end

  test "deletes chosen resource", %{conn: conn} do
    load_test = Repo.insert! %LoadTest{}
    conn = delete conn, load_test_path(conn, :delete, load_test)
    assert redirected_to(conn) == load_test_path(conn, :index)
    refute Repo.get(LoadTest, load_test.id)
  end
end
