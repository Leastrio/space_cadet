defmodule SpaceCadet.Shard.Session do
  use GenServer

  @impl true
  def init(args) do
    {:ok, args}
  end
end
