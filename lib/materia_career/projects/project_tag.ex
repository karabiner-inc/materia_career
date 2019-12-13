defmodule MateriaCareer.Projects.ProjectTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_tags" do
    field(:project_id, :id)
    field(:tag_id, :id)

    timestamps()
  end

  @doc false
  def changeset(project_tag, attrs) do
    project_tag
    |> cast(attrs, [:project_id, :tag_id])
    |> validate_required([])
  end
end
