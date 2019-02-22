defmodule MateriaCareer.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  @repo Application.get_env(:materia, :repo)

  def list_users_with_skills(status) when is_integer(status) do
    Materia.Accounts.list_users_by_params(%{"and" => [%{"status" => status}]})
    |> merge_skills
  end

  def list_users_with_skills(_status \\ nil)do
    Materia.Accounts.list_users()
    |> merge_skills
  end

  def get_user_with_skills!(user_id) do
    user = Materia.Accounts.get_user!(user_id)
    skills = MateriaCareer.Features.list_my_skills(user_id)
    user |> Map.put(:skills, skills)
  end

  defp merge_skills(users) do
    skills = MateriaCareer.Features.list_skills()
    users
    |> Enum.map(fn user ->
      user_skills = skills |> Enum.filter(fn %{user_id: user_id} -> user_id == user.id end)
      user |> Map.put(:skills, user_skills)
    end)
  end

end
