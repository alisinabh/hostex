defmodule Hostex.AuthPlug do
  @moduledoc """
  Authorization plug for Hostex upload APIs.
  """

  import Plug.Conn
  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        if token == Hostex.upload_token() do
          conn
        else
          unauthorized(conn)
        end

      _ ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> send_resp(401, "UNAUTHORIZED")
    |> halt
  end
end
