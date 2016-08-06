defmodule Elt.LoadTestTest do
  use Elt.ModelCase

  alias Elt.LoadTest

  @valid_attrs %{amount_of_requests: 42, average_request_time: 42, plan: "some content", successful_requests: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LoadTest.changeset(%LoadTest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LoadTest.changeset(%LoadTest{}, @invalid_attrs)
    refute changeset.valid?
  end
end
