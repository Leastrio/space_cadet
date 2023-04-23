defmodule SpaceCadet.Model.State do
  defstruct [
    :token,
    :conn,
    :websocket,
    :request_ref,
    :status,
    :resp_headers
  ]
end
