defmodule Hostex do
  @moduledoc """
  Documentation for `Hostex`.
  """

  require Logger

  @doc """
  Returns storage dir of file in Hostex.
  """
  def storage_dir do
    System.get_env("HOSTEX_STORAGE_PATH", "/tmp/hostex")
  end

  @doc """
  If the `storage_dir()` does not exist, creates in using `mkdir -p`. 
  """
  def ensure_storage_dir_exists do
    if not File.exists?(storage_dir()) do
      Logger.info("Creating directory at #{storage_dir()}")
      :ok = File.mkdir_p(storage_dir())
    end

    :ok
  end

  @doc """
  Creates a random url friendly string for use in  
  """
  def rand_url_id do
    System.get_env("HOSTEX_URL_RAND_SIZE", "8")
    |> String.to_integer()
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  @doc """
  Returns date strings like `2020-08-08`.

  It uses Date.utc_today() by default.
  """
  def date_string(date \\ Date.utc_today()), do: Date.to_iso8601(date)

  if Mix.env() == :test do
    def random_auth_token, do: "testtoken"
  else
    @doc false
    def random_auth_token do
      token =
        32
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)

      IO.puts(
        "\e[31mA random authentication token has been generated because HOSTEX_UPLOAD_TOKEN was not provided. " <>
          "Please consider setting it so your token persists between restarts\n" <>
          "Temporary Token: #{token}\e[0m"
      )

      token
    end
  end

  @doc false
  def initialize_token do
    token = System.get_env("HOSTEX_UPLOAD_TOKEN")

    token =
      if token do
        token
      else
        random_auth_token()
      end

    Application.put_env(:hostex, :upload_token, token)
  end

  @doc """
  Returns the upload token for Hostex.

      iex> Hostex.upload_token()
      "testtoken"
  """
  def upload_token do
    Application.get_env(:hostex, :upload_token)
  end
end
