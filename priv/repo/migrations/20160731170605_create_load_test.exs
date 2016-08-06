defmodule Elt.Repo.Migrations.CreateLoadTest do
  use Ecto.Migration

  def change do
    create table(:load_tests) do
      add :amount_of_requests, :integer
      add :successful_requests, :integer
      add :average_request_time, :float
      add :plan, :string

      timestamps()
    end

  end
end
