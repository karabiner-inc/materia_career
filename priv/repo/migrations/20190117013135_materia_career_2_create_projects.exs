defmodule MateriaCareer.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add(:title, :string)
      add(:thumbnail_img_url, :string)
      add(:back_ground_img_url, :string)
      add(:overview, :string)
      add(:description, :string, size: 3000)
      add(:organization_id, references(:organizations))
      add(:project_category, :string)
      add(:project_start_date, :utc_datetime)
      add(:project_end_date, :utc_datetime)
      add(:work_start_date, :utc_datetime)
      add(:work_end_date, :utc_datetime)
      add(:status, :integer)
      add(:pay, :bigint)
      add(:work_style, :string)
      add(:location, :string)
      add(:lock_version, :bigint)

      timestamps()
    end

    create(index(:projects, [:organization_id]))
  end
end
