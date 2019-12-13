defmodule MateriaCareer.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:label, :string)

      timestamps()
    end

    create(index(:tags, [:label]))
  end
end
