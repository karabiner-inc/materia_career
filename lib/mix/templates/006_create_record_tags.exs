defmodule MateriaCareer.Repo.Migrations.CreateRecordTags do
  use Ecto.Migration

  def change do
    create table(:record_tags) do
      add :record_id, references(:records, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end
    create index(:record_tags, [:record_id])
    create index(:record_tags, [:tag_id])
  end
end
