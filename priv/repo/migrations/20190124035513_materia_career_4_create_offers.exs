defmodule MateriaCareer.Repo.Migrations.CreateOffers do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :message_subject, :string
      add :offer_message, :string
      add :answer_message, :string
      add :status, :integer
      add :lock_version, :bigint
      add :project_id, references(:projects, on_delete: :nothing)
      add :from_user_id, references(:users, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)
      add :offer_time, :utc_datetime
      add :answer_time, :utc_datetime

      timestamps()
    end

    create index(:offers, [:project_id, :status, :message_subject])
    create index(:offers, [:from_user_id, :status, :message_subject])
    create index(:offers, [:to_user_id, :status, :message_subject])
  end
end
