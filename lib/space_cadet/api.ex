defmodule SpaceCadet.Api do
  def start do
    children = [
      {
        Finch,
        name: SpaceCadet.RestClient,
        pools: %{
          "https://discord.com" => [size: 50, count: 1]
        }
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def request(token, method, endpoint, body \\ nil) do
    Finch.build(method, "https://discord.com/api/v10" <> endpoint, [{"Authorization", "Bot " <> token}], body)
      |> Finch.request(SpaceCadet.RestClient)
      |> elem(1)
      |> Map.get(:body)
      |> Jason.decode(keys: :atoms)
      |> elem(1)
  end
end
