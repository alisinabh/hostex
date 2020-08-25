defmodule Hostex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Hostex.ensure_storage_dir_exists()
    Hostex.initialize_token()

    children = [
      # Starts a worker by calling: Hostex.Worker.start_link(arg)
      # {Hostex.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Hostex.Router, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hostex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
