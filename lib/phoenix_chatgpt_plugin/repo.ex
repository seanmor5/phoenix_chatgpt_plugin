defmodule PhoenixChatgptPlugin.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_chatgpt_plugin,
    adapter: Ecto.Adapters.Postgres
end
