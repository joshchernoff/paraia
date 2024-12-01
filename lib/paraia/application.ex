defmodule Paraia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ParaiaWeb.Telemetry,
      Paraia.Repo,
      {DNSCluster, query: Application.get_env(:paraia, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Paraia.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Paraia.Finch},
      {Paraia.Client.BlueSky.JetStream, []},

      # Start a worker by calling: Paraia.Worker.start_link(arg)
      # {Paraia.Worker, arg},
      # Start to serve requests, typically the last entry
      ParaiaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Paraia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ParaiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
