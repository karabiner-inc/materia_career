defmodule MateriaCareerWeb.ProjectController do
  use MateriaCareerWeb, :controller

  alias MateriaCareer.Projects
  alias MateriaCareer.Projects.Project

  alias Materia.Errors.BusinessError

  action_fallback MateriaWeb.FallbackController

  def index(conn, _params) do
    projects = Projects.list_projects()
    render(conn, "index.json", projects: projects)
  end

  def create(conn, project_params) do
    with {:ok, %Project{} = project} <- Projects.create_project(project_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_path(conn, :show, project))
      |> render("show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, "show.json", project: project)
  end

  def update(conn, project_params) do
    project = Projects.get_project!(project_params["id"])

    with {:ok, %Project{} = project} <- Projects.update_project(project, project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    with {:ok, %Project{}} <- Projects.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end

  def list_my_plojects(conn, %{"status_list" => status_list}) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)

    projects = Projects.list_project_by_user_id(user_id, status_list)
    render(conn, "index.json", projects: projects)
  end

  def create_my_project(conn, project_params) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)

    MateriaWeb.ControllerBase.transaction_flow(conn, :project, Projects, :create_my_project, [user_id, project_params])
  end

  def update_my_project(conn, project_params) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)

    MateriaWeb.ControllerBase.transaction_flow(conn, :project, Projects, :update_project, [user_id, project_params])
  end

end
