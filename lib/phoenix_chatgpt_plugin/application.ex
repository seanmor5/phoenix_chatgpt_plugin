defmodule PhoenixChatgptPlugin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PhoenixChatgptPluginWeb.Telemetry,
      # Start the Ecto repository
      PhoenixChatgptPlugin.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixChatgptPlugin.PubSub},
      # Start Finch
      {Finch, name: PhoenixChatgptPlugin.Finch},
      {Nx.Serving,
        name: PhoenixChatgptPlugin.Serving.Similarity,
        serving: PhoenixChatgptPlugin.Serving.Similarity.serving(batch_size: 8),
        defn_options: [compiler: EXLA],
        batch_timeout: 100
      },
      # Start the Endpoint (http/https)
      PhoenixChatgptPluginWeb.Endpoint
      # Start a worker by calling: PhoenixChatgptPlugin.Worker.start_link(arg)
      # {PhoenixChatgptPlugin.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixChatgptPlugin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixChatgptPluginWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
