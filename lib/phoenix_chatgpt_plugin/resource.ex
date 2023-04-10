defmodule PhoenixChatgptPlugin.Resource do
  import Ecto.Query
  import Pgvector.Ecto.Query

  alias PhoenixChatgptPlugin.Repo
  alias PhoenixChatgptPlugin.Resource.Document

  @doc """
  Creates a new document.
  """
  def create_document(attrs) do
    %Document{}
    |> Document.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves the top `k` documents nearest to the
  given embedding.
  """
  def retrieve_closest_documents(embedding, k) do
    Document
    |> order_by([d], max_inner_product(d.embedding, ^embedding))
    |> limit(^k)
    |> Repo.all()
  end
end