defmodule MateriaCareer.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Materia.Accounts
  alias MateriaCareer.Projects.Project
  alias MateriaCareer.Tags

  alias Materia.Organizations.Organization
  alias MateriaUtils.Calendar.CalendarUtil
  alias Materia.Errors.BusinessError

  @repo Application.get_env(:materia, :repo)
  require Logger

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Project
    |> @repo.all()
    |> @repo.preload(:organization)
  end

  def list_project_by_user_id(user_id, status_list) when is_list(status_list) do
    user = Materia.Accounts.get_user!(user_id)
    Project
    |> where([p], p.organization_id == ^user.organization.id)
    |> where([p], p.status in ^status_list)
    |> @repo.all()
    |> @repo.preload(:organization)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: @repo.get!(Project, id) |> @repo.preload(:organization)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> @repo.insert()
  end

  def create_my_project(_result, user_id, attrs \\ %{}) do
    user =
      user_id
      |> Accounts.get_user!()
      |> @repo.preload(:organization)

    project =
      attrs
      |> CalendarUtil.parse_datetime_strftime(["project_start_date","project_end_date","work_start_date","work_end_date"])
      |> CalendarUtil.convert_time_local2utc(["project_start_date","project_end_date","work_start_date","work_end_date"]) 
      |> Map.put("organization_id", user.organization.id)
      |> create_project()
      |> get_ok()
      |> merge_tags(attrs["project_tags"])
      |> @repo.preload(:organization)
      |> @repo.preload(:project_tags)

    {:ok, project}
  end

  defp get_ok({:ok, value}) do
    value
  end

  def update_project(_result, user_id, attrs) do
    projects = list_project_by_user_id(user_id, Map.values(Project.status()))

    project =
      projects
      |> Enum.find(fn project -> project.id == attrs["id"] end)

    if project == nil do
      raise BusinessError, message: "project not found. project_id:#{attrs["id"]}"
    end

    {:ok, project} = update_project(project, attrs)

    project =
      project
      |> merge_tags(attrs["project_tags"])
      |> @repo.preload(:project_tags)

    {:ok, project}
  end

  def merge_tags(project, tags) do
    tags =
      if tags == nil do
        Logger.debug("#{__MODULE__} merge_tags. skip merge_tags. project_tags == nil")
        []
      else
        tags
        |> Enum.map(fn tag ->
          {:ok, tag} = Tags.merge_tag(tag)
          tag
        end)
      end

    merge_project_tags(project, tags)

    project =
      project
      |> Map.put(:project_tags, tags)
  end

  def merge_project_tags(project, tags) do
    {:ok, project_tags} = get_project_tag_by_project_id_with_lock(%{}, project.id)

    # tagsにあってproject_tagsにないtagを追加
    tags
    |> Enum.map(fn tag ->
      if Enum.any?(project_tags, fn project_tag -> project_tag.tag_id == tag.id end) do
        Logger.debug(
          "#{__MODULE__} merge_project_tags. skip project_tag. project_id:#{project.id} tag_id:#{
            tag.id
          }"
        )
      else
        {:ok, project_tag} = create_project_tag(%{project_id: project.id, tag_id: tag.id})
      end
    end)

    # 逆にproject_tagsにあって、tagsにないtagを削除
    project_tags
    |> Enum.map(fn project_tag ->
      if Enum.any?(tags, fn tag -> project_tag.tag_id == tag.id end) do
        Logger.debug(
          "#{__MODULE__} merge_project_tags. skip tag. project_id:#{project.id} tag_id:#{
            project_tag.id
          }"
        )
      else
        {:ok, result} = delete_project_tag(project_tag)
      end
    end)
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.update_changeset(attrs)
    |> @repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project), do: @repo.delete(project)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end

  alias MateriaCareer.Projects.ProjectTag

  @doc """
  Returns the list of project_tags.

  ## Examples

      iex> list_project_tags()
      [%ProjectTag{}, ...]

  """
  # def list_project_tags do
  #  Repo.all(ProjectTag)
  # end

  @doc """
  Gets a single project_tag.

  Raises `Ecto.NoResultsError` if the Project tag does not exist.

  ## Examples

      iex> get_project_tag!(123)
      %ProjectTag{}

      iex> get_project_tag!(456)
      ** (Ecto.NoResultsError)

  """
  # def get_project_tag!(id), do: Repo.get!(ProjectTag, id)

  def get_project_tag_by_project_id_with_lock(_result, project_id) do
    project_tags =
      ProjectTag
      |> where(project_id: ^project_id)
      |> lock("FOR UPDATE")
      |> @repo.all()

    {:ok, project_tags}
  end

  @doc """
  Creates a project_tag.

  ## Examples

      iex> create_project_tag(%{field: value})
      {:ok, %ProjectTag{}}

      iex> create_project_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_tag(attrs \\ %{}) do
    %ProjectTag{}
    |> ProjectTag.changeset(attrs)
    |> @repo.insert()
  end

  @doc """
  Updates a project_tag.

  ## Examples

      iex> update_project_tag(project_tag, %{field: new_value})
      {:ok, %ProjectTag{}}

      iex> update_project_tag(project_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_tag(%ProjectTag{} = project_tag, attrs) do
    project_tag
    |> ProjectTag.changeset(attrs)
    |> @repo.update()
  end

  @doc """
  Deletes a ProjectTag.

  ## Examples

      iex> delete_project_tag(project_tag)
      {:ok, %ProjectTag{}}

      iex> delete_project_tag(project_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_tag(%ProjectTag{} = project_tag) do
    @repo.delete(project_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_tag changes.

  ## Examples

      iex> change_project_tag(project_tag)
      %Ecto.Changeset{source: %ProjectTag{}}

  """
  def change_project_tag(%ProjectTag{} = project_tag) do
    ProjectTag.changeset(project_tag, %{})
  end
end
