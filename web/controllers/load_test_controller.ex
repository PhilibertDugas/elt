defmodule Elt.LoadTestController do
  use Elt.Web, :controller

  alias Elt.LoadTest

  def index(conn, _params) do
    load_tests = Repo.all(LoadTest)
    render(conn, "index.html", load_tests: load_tests)
  end

  def new(conn, _params) do
    changeset = LoadTest.changeset(%LoadTest{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"load_test" => load_test_params}) do
    {:ok, task} = Task.start(fn -> Runner.main(load_test_params["plan"]) end)
    Map.Bucket.put("1", task)
    conn
      |> redirect(to: load_test_path(conn, :progress, "1"))
  end

  def progress(conn, %{"id" => id}) do
    task = Map.Bucket.get("1")
    case Process.alive?(task) do
      true ->
        render(conn, "progress.html", alive: true)
      false ->
        insert_result(conn)
    end
  end

  defp insert_result(conn) do
    result = List.Bucket.get_all
    List.Bucket.clean
    requests = LoadTest.count_requests(result)
    success = LoadTest.count_successes(result)
    average = LoadTest.count_average_request_time(result)
    changeset = LoadTest.changeset(
      %LoadTest{},
      %{amount_of_requests: requests, successful_requests: success, average_request_time: average, plan: "test"}
    )

    case Repo.insert(changeset) do
      {:ok, _load_test} ->
        conn
        |> put_flash(:info, "Load test created successfully.")
        |> redirect(to: load_test_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    load_test = Repo.get!(LoadTest, id)
    render(conn, "show.html", load_test: load_test)
  end

  def edit(conn, %{"id" => id}) do
    load_test = Repo.get!(LoadTest, id)
    changeset = LoadTest.changeset(load_test)
    render(conn, "edit.html", load_test: load_test, changeset: changeset)
  end

  def update(conn, %{"id" => id, "load_test" => load_test_params}) do
    load_test = Repo.get!(LoadTest, id)
    changeset = LoadTest.changeset(load_test, load_test_params)

    case Repo.update(changeset) do
      {:ok, load_test} ->
        conn
        |> put_flash(:info, "Load test updated successfully.")
        |> redirect(to: load_test_path(conn, :show, load_test))
      {:error, changeset} ->
        render(conn, "edit.html", load_test: load_test, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    load_test = Repo.get!(LoadTest, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(load_test)

    conn
    |> put_flash(:info, "Load test deleted successfully.")
    |> redirect(to: load_test_path(conn, :index))
  end
end
