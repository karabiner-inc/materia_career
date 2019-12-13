defmodule MateriaCareer.Features.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skills" do
    field(:end_date, :date)
    field(:name, :string)
    field(:start_date, :date)
    field(:subject, :string)
    # field :user_id, :id
    belongs_to(:user, Materia.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:subject, :name, :start_date, :end_date, :user_id])
    |> validate_required([:subject, :name])
  end
end
