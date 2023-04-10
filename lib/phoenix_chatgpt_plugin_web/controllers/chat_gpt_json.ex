defmodule PhoenixChatgptPluginWeb.ChatGPTJSON do
  
  def search(%{matches: matches}) do
    %{data: (for match <- matches, do: data(match))}
  end

  defp data(%{title: title, contents: contents}) do
    %{
      title: title,
      contents: contents
    }
  end
end