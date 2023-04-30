defmodule SpaceCadet.Utils do
  def extract_id(token) do
    [id, _, _] = String.split(token, ".")

    case Base.decode64(id) do
      {:ok, id} -> id
      :error -> raise "Invalid token provided"
    end
  end
end
