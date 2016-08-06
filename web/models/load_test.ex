defmodule Elt.LoadTest do
  use Elt.Web, :model

  schema "load_tests" do
    field :amount_of_requests, :integer
    field :successful_requests, :integer
    field :average_request_time, :float
    field :plan, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount_of_requests, :successful_requests, :average_request_time, :plan])
    |> validate_required([:amount_of_requests, :successful_requests, :average_request_time, :plan])
  end

  def count_requests(result) do
    length result
  end

  def count_successes(result) do
    Enum.map(result, fn(x) -> elem(x, 0) == "true" end) |> length
  end

  def count_average_request_time(result) do
    {_, total_time} = Enum.map_reduce(result, 0, fn(x, acc) -> {elem(x, 1), elem(x, 1) + acc} end)
    total_time / length result
  end
end
