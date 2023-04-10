defmodule PhoenixChatgptPlugin.Repo.Migrations.CreateDocumentsTable do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string
      add :contents, :text
      add :embedding, :vector, size: 384
    end
  end
end
