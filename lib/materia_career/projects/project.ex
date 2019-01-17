defmodule MateriaCareer.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset


  schema "projects" do
    field :back_ground_img_url, :string
    field :description, :string
    field :thumbnail_img_url, :string
    field :overview, :string
    field :title, :string
    field :project_category, :string
    field :project_start_date, :utc_datetime
    field :project_end_date, :utc_datetime
    field :work_start_date, :utc_datetime
    field :work_end_date, :utc_datetime
    field :status, :integer, default: 1
    field :pay, :integer
    field :work_style, :string
    field :location, :string
    field :lock_version, :integer, default: 0

    belongs_to :organization, Materia.Organizations.Organization
    many_to_many :project_tags, MateriaCareer.Tags.Tag, join_through: "project_tags"

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :thumbnail_img_url, :back_ground_img_url, :overview, :description, :project_category, :project_start_date, :project_end_date, :work_start_date, :work_end_date, :status, :pay, :work_style, :location, :organization_id, :lock_version])
    |> validate_required([:title])
    |> optimistic_lock(:lock_version)
  end

  def update_changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :thumbnail_img_url, :back_ground_img_url, :overview, :description, :project_category, :project_start_date, :project_end_date, :work_start_date, :work_end_date, :status, :pay, :work_style, :location, :organization_id, :lock_version])
    |> validate_required([:title, :lock_version])
    |> optimistic_lock(:lock_version)
  end

  def status() do
    %{
      new: 1, #募集開始前
      wanted: 2, #募集中
      paused: 8, #募集停止中
      closed: 9, #案件閉鎖済み
    }
  end

  def get_status_disp(status_value) do
    disp_map = %{
      1 => "募集前",
      2 => "募集中",
      8 => "募集停止中",
      9 => "終了済み",
    }
    disp_map[status_value]
  end

end
