defmodule MateriaCareer.Repo.Migrations.CreateProjectTag do
  use Ecto.Migration

  def change do
    create table(:project_tags) do
      add :project_id, references(:projects, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    create index(:project_tags, [:project_id])
    create index(:project_tags, [:tag_id])
  end
end
