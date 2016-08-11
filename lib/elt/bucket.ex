defmodule List.Bucket do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(value) do
    Agent.update(__MODULE__, &List.insert_at(&1, 0, value))
  end

  def get_all do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def clean do
    Agent.update(__MODULE__, fn _state -> [] end)
  end
end
