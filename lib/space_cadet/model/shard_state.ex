defmodule SpaceCadet.Model.ShardState do
  defstruct [
    :token,
    :conn,
    :websocket,
    :request_ref,
    :status,
    :resp_headers
  ]
end
