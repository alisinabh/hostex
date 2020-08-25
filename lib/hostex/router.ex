defmodule Hostex.Router do
  @moduledoc """
  Main plug for handling hostex requests.
  """

  use Plug.Router
  use Plug.ErrorHandler

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  require Logger

  alias Hostex.{UploadPlug, ServePlug}

  plug(Plug.RequestId)
  plug(Plug.Logger)

  # Serve happens here at ServePlug
  plug(ServePlug)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [
      :urlencoded,
      # Increase to 20MB max upload
      {:multipart, length: 20_000_000}
    ],
    pass: ["*/*"]
  )

  plug(:dispatch)

  # Upload routes
  post("/:name", to: UploadPlug)
  post("/", to: UploadPlug)

  match _ do
    send_resp(conn, 404, "NOT FOUND")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack} = error) do
    Logger.error("Unhandled error: #{inspect(error)}")
    send_resp(conn, conn.status, "Something went wrong")
  end
end
