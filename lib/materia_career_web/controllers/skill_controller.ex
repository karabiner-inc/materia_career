defmodule MateriaCareerWeb.SkillController do
  use MateriaCareerWeb, :controller

  alias MateriaCareer.Features
  alias MateriaCareer.Features.Skill

  action_fallback MateriaCareerWeb.FallbackController

  def index(conn, _params) do
    skills = Features.list_skills()
    render(conn, "index.json", skills: skills)
  end

  def create(conn, %{"skill" => skill_params}) do
    with {:ok, %Skill{} = skill} <- Features.create_skill(skill_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", skill_path(conn, :show, skill))
      |> render("show.json", skill: skill)
    end
  end

  def show(conn, %{"id" => id}) do
    skill = Features.get_skill!(id)
    render(conn, "show.json", skill: skill)
  end

  def update(conn, %{"id" => id, "skill" => skill_params}) do
    skill = Features.get_skill!(id)

    with {:ok, %Skill{} = skill} <- Features.update_skill(skill, skill_params) do
      render(conn, "show.json", skill: skill)
    end
  end

  def delete(conn, %{"id" => id}) do
    skill = Features.get_skill!(id)
    with {:ok, %Skill{}} <- Features.delete_skill(skill) do
      send_resp(conn, :no_content, "")
    end
  end

  def list_my_skills(conn, _params) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)
    skills = Features.list_my_skills(user_id)
    render(conn, "index.json", skills: skills)
  end

  def list_user_skills(conn, %{"user_id" => user_id}) do
    skills = Features.list_my_skills(user_id)
    render(conn, "index.json", skills: skills)
  end

  def create_my_skill(conn, params) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)
    skill_params = 
      params
        |> Map.put("user_id", user_id)
    with {:ok, %Skill{} = skill} <- Features.create_skill(skill_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", skill_path(conn, :show, skill))
      |> render("show.json", skill: skill)
    end
  end

  def update_my_skill(conn, params) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)
    skill = Features.get_skill!(params["id"])
    
    with true <- skill.user_id == user_id do
      skill_params = 
      params
        |> Map.put("user_id", user_id)
      with {:ok, %Skill{} = skill} <- Features.update_skill(skill, skill_params) do
        render(conn, "show.json", skill: skill)
      end
    end
  end

  def delete_my_skill(conn, %{"id" => id}) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)
    skill = Features.get_skill!(id)
    
    with true <- skill.user_id == user_id do
      with {:ok, %Skill{}} <- Features.delete_skill(skill) do
        send_resp(conn, :no_content, "")
      end
    end

  end

end
