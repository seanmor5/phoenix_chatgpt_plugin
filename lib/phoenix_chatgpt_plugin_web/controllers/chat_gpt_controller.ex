defmodule PhoenixChatgptPluginWeb.ChatGPTController do
  use PhoenixChatgptPluginWeb, :controller

  alias PhoenixChatgptPlugin.Resource

  @top_k 3

  def search(conn, %{"query" => query}) do
    [embedding] = Nx.Serving.batched_run(PhoenixChatgptPlugin.Serving.Similarity, query)
    matches = Resource.retrieve_closest_documents(Nx.to_flat_list(embedding), @top_k)
    render(conn, :search, matches: matches)
  end
end