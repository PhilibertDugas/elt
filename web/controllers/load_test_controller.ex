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

  def create(conn, %{"load_test" => %{ "plan" => plan }}) do
    {:ok, task} = Task.start(
     fn ->
      Runner.main(plan)
      insert_result
     end
   )
    Map.Bucket.put("1", task)
    conn
      |> redirect(to: load_test_path(conn, :progress, "1"))
  end

  def create(conn, _params) do
    conn
    |> put_status(400)
    |> html("Error, wrong parameters")
  end

  def progress(conn, %{"id" => id}) do
    task = Map.Bucket.get("1")
    case Process.alive?(task) do
      true ->
        render(conn, "progress.html", alive: true)
      false ->
        conn
        |> put_flash(:info, "Load test created successfully.")
        |> redirect(to: load_test_path(conn, :index))
    end
  end

  defp insert_result do
    result = List.Bucket.get_all
    List.Bucket.clean
    requests = LoadTest.count_requests(result)
    success = LoadTest.count_successes(result)
    average = LoadTest.count_average_request_time(result)
    changeset = LoadTest.changeset(
      %LoadTest{},
      %{amount_of_requests: requests, successful_requests: success, average_request_time: average, plan: "test"}
    )
    Repo.insert(changeset)
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
