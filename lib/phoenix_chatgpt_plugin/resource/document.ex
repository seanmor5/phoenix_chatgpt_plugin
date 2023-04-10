defmodule PhoenixChatgptPlugin.Resource.Document do
  @moduledoc """
  Document schema.

  A document is a generic resource that you want to retrieve.
  For example, this could represent your company's documentation
  or your own personal data. Documents will be injected into ChatGPT's
  conversation to better guide responses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :title, :string
    field :contents, :string
    field :embedding, Pgvector.Ecto.Vector
  end

  def create_changeset(document, attrs) do
    document
    |> cast(attrs, [:title, :contents])
    |> validate_required([:title, :contents])
    |> put_embedding()
  end

  defp put_embedding(changeset) do
    title = get_field(changeset, :title)
    contents = get_field(changeset, :contents)
    doc = document(title, contents)

    [embedding] = Nx.Serving.batched_run(PhoenixChatgptPlugin.Serving.Similarity, doc)
    # TODO: Use a binary?
    embedding = Nx.to_flat_list(embedding)
    put_change(changeset, :embedding, embedding)
  end

  defp document(title, contents) do
    """
    Title: #{title}
    Contents: #{contents}
    """
  end
end