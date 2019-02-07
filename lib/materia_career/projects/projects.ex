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
      |> Enum.find(fn project -> project.id == String.to_integer(attrs["id"]) end)

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

  alias MateriaCareer.Projects.Record

  @doc """
  Returns the list of my records.

  ## Examples

      iex> list_records_by_user_id()
      [%Record{}, ...]

  """
  def list_records_by_user_id(user_id) do
    Record
    |> where([p], p.user_id == ^user_id)
    |> @repo.all()
  end

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_records()
      [%Record{}, ...]

  """
  def list_records do
    @repo.all(Record)
  end

  @doc """
  Gets a single record.

  Raises `Ecto.NoResultsError` if the Record does not exist.

  ## Examples

      iex> get_record!(123)
      %Record{}

      iex> get_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_record!(id) do
    @repo.get!(Record, id)
  end

  @doc """
  Creates a record.

  ## Examples

      iex> create_record(%{field: value})
      {:ok, %Record{}}

      iex> create_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_record(attrs \\ %{}) do
    {:ok, record} = %Record{}
    |> Record.changeset(attrs)
    |> @repo.insert()
    {:ok, record}
  end

  def create_my_record(_result, user_id, attrs \\ %{}) do
    user = Accounts.get_user!(user_id)
    attrs = Map.put(attrs, "user_id", user.id)

    attrs =
    if attrs["project_id"] == nil do
        attrs
    else
        project = get_project!(attrs["project_id"])
        Map.put(attrs, "project_id", project.id)
    end
    {:ok, record} = create_record(attrs)
    tags = attrs["tags"]
    merge_record_tag(record, tags)
    record = preload_record(record)

    {:ok, record}
  end

  def update_my_record(_result, user_id, attrs \\ %{}) do

    records = list_records_by_user_id(user_id)

    record = records
    |> Enum.find(fn(record) -> record.id == String.to_integer(attrs["id"]) end)

    if record == nil do
      Logger.debug("#{__MODULE__} update_my_record. record id:#{attrs["id"]} not found.")
      raise ServicexError, message:  "record id:#{attrs["id"]} was not found."
    end

    attrs =
    if attrs["project_id"] == nil do
        attrs
    else
        project = get_project!(attrs["project_id"])
        Map.put(attrs, "project_id", project.id)
    end
    {:ok, record} = update_record(record, attrs)

    IO.inspect(record)

    tags = attrs["tags"]
    merge_record_tag(record, tags)
    record = preload_record(record)

    {:ok, record}
  end

  def preload_record(record) do
    record
    |> @repo.preload(:user)
    |> @repo.preload(:project)
    |> @repo.preload(:tags)
  end

  def merge_record_tag(record, tags) do
    tags =
        if tags == nil do
            []
        else
            tags
            |> Enum.map(fn(tag) ->
                {:ok, tag} = Tags.merge_tag(tag)
                tag
            end)
        end
        merge_record_tags(record, tags)
  end

  @doc """
  Updates a record.

  ## Examples

      iex> update_record(record, %{field: new_value})
      {:ok, %Record{}}

      iex> update_record(record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_record(%Record{} = record, attrs) do
    record
    |> Record.update_changeset(attrs)
    |> @repo.update()
  end

  @doc """
  Deletes a Record.

  ## Examples

      iex> delete_record(record)
      {:ok, %Record{}}

      iex> delete_record(record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_record(%Record{} = record) do
    @repo.delete(record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking record changes.

  ## Examples

      iex> change_record(record)
      %Ecto.Changeset{source: %Record{}}

  """
  def change_record(%Record{} = record) do
    Record.changeset(record, %{})
  end

  alias MateriaCareer.Projects.RecordTag

  @doc """
  Creates a record_tag.

  ## Examples

      iex> create_record_tag(%{field: value})
      {:ok, %RecordTag{}}

      iex> create_record_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_record_tag(attrs \\ %{}) do
    %RecordTag{}
    |> RecordTag.changeset(attrs)
    |> @repo.insert()
  end

  @doc """
  Deletes a RecordTag.

  ## Examples

      iex> delete_record_tag(record_tag)
      {:ok, %RecordTag{}}

      iex> delete_record_tag(record_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_record_tag(%RecordTag{} = record_tag) do
    @repo.delete(record_tag)
  end

  # alias MateriaCareer.Projects.UserProfileTag


  # def create_user_profile_tag(attrs \\ %{}) do
  #   %UserProfileTag{}
  #   |> UserProfileTag.changeset(attrs)
  #   |> @repo.insert()
  # end

  # @doc """
  # Deletes a UserProfileTag.

  # ## Examples

  #     iex> delete_user_profile_tag(user_profile_tag)
  #     {:ok, %UserProfileTag{}}

  #     iex> delete_user_profile_tag(user_profile_tag)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_user_profile_tag(%UserProfileTag{} = user_profile_tag) do
  #   @repo.delete(user_profile_tag)
  # end

  def get_record_tag_by_record_id_with_lock(_result, record_id) do
    record_tags = RecordTag
    |> where(record_id: ^record_id)
    |> @repo.all()
    {:ok, record_tags}
  end

  def merge_record_tags(record, tags) do
    {:ok, record_tags}  = get_record_tag_by_record_id_with_lock(%{}, record.id)
    tags
    |> Enum.map(fn(tag) ->
        if Enum.any?(record_tags, fn(record_tag) -> record_tag.tag_id == tag.id end) do
            Logger.debug("#{__MODULE__} merge_record_tags. skip record_tag. record_id:#{record.id} tag_id:#{tag.id}")
        else
            {:ok, _record_tag} = create_record_tag(%{record_id: record.id, tag_id: tag.id})
        end
    end)
    record_tags
    |> Enum.map(fn(record_tag) ->
        if Enum.any?(tags, fn(tag) -> record_tag.tag_id == tag.id end) do
            Logger.debug("#{__MODULE__} merge_record_tags. skip tag. record_id:#{record.id} tag_id:#{record_tag.tag_id}")
        else
            {:ok, _result} = delete_record_tag(record_tag)
        end
    end)
  end

  # def merge_user_profile_tags(user_profile, tags) do
  #   {:ok, user_profile_tags}  = get_user_profile_tag_by_user_profile_id_with_lock(%{}, user_profile.id)

  #   # tagsにあってuser_profile_tagsにないtagを追加
  #   tags
  #   |> Enum.map(fn(tag) ->
  #       if Enum.any?(user_profile_tags, fn(user_profile_tag) -> user_profile_tag.tag_id == tag.id end) do
  #           Logger.debug("#{__MODULE__} merge_user_profile_tags. skip user_profile_tag. user_profile_id:#{user_profile.id} tag_id:#{tag.id}")
  #       else
  #           {:ok, _user_profile_tag} = create_user_profile_tag(%{user_profile_id: user_profile.id, tag_id: tag.id})
  #       end
  #   end)
  #   # 逆にuser_profile_tagsにあって、tagsにないtagを削除
  #   user_profile_tags
  #   |> Enum.map(fn(user_profile_tag) ->
  #       if Enum.any?(tags, fn(tag) -> user_profile_tag.tag_id == tag.id end) do
  #           Logger.debug("#{__MODULE__} merge_user_profile_tags. skip tag. user_profile_id:#{user_profile.id} tag_id:#{user_profile_tag.id}")
  #       else
  #           {:ok, _result} = delete_user_profile_tag(user_profile_tag)
  #       end
  #   end)

  # end

  # def get_user_profile_tag_by_user_profile_id_with_lock(_result, user_profile_id) do
  #   user_profiles = UserProfileTag
  #   |> where(user_profile_id: ^user_profile_id)
  #   |> lock("FOR UPDATE")
  #   |> @repo.all()
  #   {:ok, user_profiles}

  # end

  # def create_joiner(result, attrs) do
  #   {:ok, user_profile} = Accounts.create_user_profile(result, attrs)
  #   user_profile = user_profile
  #   |> merge_tags(attrs["user_profile_tags"])
  #   |> @repo.preload([:user])

  #   {:ok, user_profile}
  # end

  # def update_joiner(result, user_id, attrs) do

  #   {:ok, user_profile} = Accounts.update_user_profile(result, user_id, attrs)

  #   user_profile = user_profile
  #   |> merge_tags(attrs["user_profile_tags"])
  #   |> @repo.preload([:user])

  #   {:ok, user_profile}
  # end

  # def merge_tags(user_profile, tags) do
  #   tags =
  #   if tags == nil do
  #       Logger.debug("#{__MODULE__} merge_tags. skip merge_tags. user_profile_tags == nil")
  #       []
  #   else
  #       tags
  #       |> Enum.map(fn(tag) ->
  #           {:ok, tag} = Tags.merge_tag(tag)
  #           tag
  #       end)
  #   end
  #   merge_user_profile_tags(user_profile, tags)
  #   user_profile
  #   |> Map.put(:user_profile_tags, tags)
  # end

end
