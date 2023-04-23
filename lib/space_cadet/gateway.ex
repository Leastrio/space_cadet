defmodule SpaceCadet.Gateway do
  use GenServer
  require Logger

  alias SpaceCadet.Model.State

  def start_link(token) do
    if token == nil do
      raise "Token not provided"
    end

    GenServer.start_link(__MODULE__, %State{token: token}, name: __MODULE__)
  end

  def init(%State{token: token} = state) do
    uri = SpaceCadet.Api.request(token, :get, "/gateway/bot").url <> "/?v=10&encoding=etf" |> URI.parse()
    path = uri.path <> "?" <> uri.query

    with {:ok, conn} <- Mint.HTTP.connect(:https, uri.host, uri.port),
         {:ok, conn, ref} <- Mint.WebSocket.upgrade(:wss, conn, path, []) do
            state = %State{state | conn: conn, request_ref: ref}
            {:ok, state}
         else
          {:error, reason} ->
            {:stop, reason}

          {:error, _conn, reason} ->
            {:stop, reason}
         end
  end

  def handle_info(msg, state) do
    case Mint.WebSocket.stream(state.conn, msg) do
      {:ok, conn, responses} ->
        state = put_in(state.conn, conn) |> handle_responses(responses)
        {:noreply, state}
    end
  end

  defp handle_responses(state, responses)

  defp handle_responses(%{request_ref: ref} = state, [{:status, ref, status} | rest]) do
    put_in(state.status, status)
    |> handle_responses(rest)
  end

  defp handle_responses(%{request_ref: ref} = state, [{:headers, ref, resp_headers} | rest]) do
    put_in(state.resp_headers, resp_headers)
    |> handle_responses(rest)
  end

  defp handle_responses(%{request_ref: ref} = state, [{:done, ref} | rest]) do
    case Mint.WebSocket.new(state.conn, ref, state.status, state.resp_headers) do
      {:ok, conn, websocket} ->
        %{state | conn: conn, websocket: websocket, status: nil, resp_headers: nil}
        |> reply({:ok, :connected})
        |> handle_responses(rest)
    end
  end

  defp handle_responses(%{request_ref: ref, websocket: websocket} = state, [
    {:data, ref, data} | rest
  ])
  when websocket != nil do
    case Mint.WebSocket.decode(websocket, data) do
    {:ok, websocket, frames} ->
      put_in(state.websocket, websocket)
      |> handle_frames(frames)
      |> handle_responses(rest)

    {:error, websocket, reason} ->
      put_in(state.websocket, websocket)
      |> reply({:error, reason})
    end
  end

  defp handle_responses(state, [_response | rest]) do
    handle_responses(state, rest)
  end

  defp handle_responses(state, []), do: state

  def handle_frames(state, frames) do
    Enum.reduce(frames, state, fn
      {:close, _code, reason}, state ->
        Logger.debug("Closing connection: #{inspect(reason)}")
        state

      {:text, text}, state ->
        Logger.debug("Received: #{inspect(text)}")
        state

      frame, state ->
        Logger.debug("Unexpected frame received: #{inspect(frame)}")
        state
    end)
  end

  defp reply(state, response) do
    if state.caller, do: GenServer.reply(state.caller, response)
    put_in(state.caller, nil)
  end
end
