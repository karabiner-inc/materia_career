defmodule MateriaCareer.Projects.RecordTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "record_tags" do
    field(:record_id, :id)
    field(:tag_id, :id)

    timestamps()
  end

  @doc false
  def changeset(record_tag, attrs) do
    record_tag
    |> cast(attrs, [:record_id, :tag_id])
    |> validate_required([])
  end
end
