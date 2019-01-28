defmodule MateriaCareer.Projects.Record do
  use Ecto.Schema
  import Ecto.Changeset


  schema "records" do
    field :discription, :string
    field :title, :string
    field :lock_version, :integer, default: 0
    belongs_to :user, Materia.Accounts.User
    belongs_to :project, MateriaCareer.Projects.Project
    many_to_many :tags, MateriaCareer.Tags.Tag, join_through: "record_tags"

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:title, :discription, :user_id, :project_id, :lock_version])
    |> validate_required([:user_id, :title, :discription])
    |> optimistic_lock(:lock_version)
  end

  def update_changeset(record, attrs) do
    record
    |> cast(attrs, [:title, :discription, :user_id, :project_id, :lock_version])
    |> validate_required([:lock_version])
    |> optimistic_lock(:lock_version)
  end
end
