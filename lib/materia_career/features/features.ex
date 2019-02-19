defmodule MateriaCareer.Features do
  @moduledoc """
  The Features context.
  """

  import Ecto.Query, warn: false

  alias MateriaCareer.Features.Skill
  alias Materia.Errors.BusinessError

  @repo Application.get_env(:materia, :repo)
  require Logger

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills do
    @repo.all(Skill)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(id), do: @repo.get!(Skill, id)

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs \\ %{}) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> @repo.insert()
  end

  @doc """
  Creates a skills.

  ## Examples

      iex> create_my_skills([%{field: value}, %{field: value}, %{field: value}])
      {:ok, [%Skill{}, %Skill{}, %Skill{}]}

      iex> create_my_skills([%{field: bad_value}])
      ** (Ecto.NoResultsError)

  """
  def create_my_skills(user_id, attrs \\ [], is_delete) do
    with {:ok, %{skills: result}} <- create_my_skills_multi(user_id, attrs, is_delete) do
      {:ok, result}
    else
      {:error, :skills, [changeset | _], _} ->
        Logger.debug("#{__MODULE__} transaction_flow. Ecto.Multi transaction was failed. errors")
        changeset
    end
  end

  defp create_my_skills_multi(user_id, attrs, is_delete) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:skills, fn _ ->

      if is_delete do
        from(s in Skill, where: s.user_id == ^user_id)
        |> @repo.delete_all
      end

      result =
        attrs
        |> Enum.map(&(Map.put(&1, "user_id", user_id)))
        |> Enum.map(&create_skill(&1))

      errors =
        result |> Enum.filter(fn {is_ok_or_error, _} -> is_ok_or_error == :error end)

      errors_count = errors |> Enum.count()

      cond do
        errors_count == 0 ->
          result = result |> Enum.map(fn {_, value} -> value end)
          {:ok, result}

        true ->
          {:error, errors}
      end
    end)
    |> @repo.transaction() 
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> @repo.update()
  end

  @doc """
  Deletes a Skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Skill{} = skill) do
    @repo.delete(skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{source: %Skill{}}

  """
  def change_skill(%Skill{} = skill) do
    Skill.changeset(skill, %{})
  end

  @doc """
  Returns the list of my skills.

  ## Examples

      iex> list_my_skills()
      [%Skill{}, ...]

  """
  def list_my_skills(user_id) do
    Skill
    |> where([p], p.user_id == ^user_id)
    |> @repo.all()
  end
end
