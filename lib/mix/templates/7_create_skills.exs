defmodule MateriaCareer.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :subject, :string
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:skills, [:user_id])
  end
end
