defmodule MateriaCareer.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :title, :string
      add :discription, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)
      add :lock_version, :bigint

      timestamps()
    end
    create index(:records, [:user_id])
    create index(:records, [:project_id])
  end
end
