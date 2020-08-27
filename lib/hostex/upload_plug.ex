defmodule Hostex.UploadPlug do
  @moduledoc """
  This plug handles upload requests. Authentication in upload requests is necessary.
  """

  use Plug.Builder

  import Plug.Conn

  require Logger

  alias Hostex.AuthPlug

  @uploads_dir "uploads"

  plug(AuthPlug)

  def init(opts), do: opts

  def call(%{params: %{"file" => %Plug.Upload{} = file}} = conn, opts) do
    case super(conn, opts) do
      %{halted: true} = conn ->
        conn

      conn ->
        original_dir = Path.join(Hostex.date_string(), Hostex.rand_url_id())
        save_dir = Path.join([Hostex.storage_dir(), @uploads_dir, original_dir])
        filename = conn.params["name"] || file.filename

        # Create save directory
        File.mkdir_p!(save_dir)

        save_path = Path.join(save_dir, filename)

        Logger.debug(fn -> "Saving to #{save_path}" end)

        case File.rename(file.path, save_path) do
          :ok -> :ok
          {:error, :exdev} -> File.cp(file.path, save_path)
        end

        resp =
          Jason.encode!(%{url: Path.join(original_dir, filename), mime: MIME.from_path(filename)})

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, resp)
    end
  end

  def call(conn, _) do
    send_resp(conn, 400, "`file` not provided!")
  end
end
