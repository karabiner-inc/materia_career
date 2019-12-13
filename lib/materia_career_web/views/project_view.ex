defmodule MateriaCareerWeb.ProjectView do
  use MateriaCareerWeb, :view
  alias MateriaCareerWeb.ProjectView

  alias MateriaWeb.OrganizationView
  alias MateriaCareerWeb.TagView
  alias MateriaCareer.Projects.Project
  alias MateriaUtils.Calendar.CalendarUtil

  def render("index.json", %{projects: projects}) do
    render_many(projects, ProjectView, "project.json")
  end

  def render("show.json", %{project: project}) do
    render_one(project, ProjectView, "project.json")
  end

  def render("project.json", %{project: project}) do
    project_map = %{
      id: project.id,
      title: project.title,
      thumbnail_img_url: project.thumbnail_img_url,
      back_ground_img_url: project.back_ground_img_url,
      overview: project.overview,
      description: project.description,
      project_category: project.project_category,
      project_start_date: project.project_start_date,
      project_end_date: project.project_end_date,
      work_start_date: project.work_start_date,
      work_end_date: project.work_end_date,
      status: project.status,
      status_disp: Project.get_status_disp(project.status),
      pay: project.pay,
      work_style: project.work_style,
      location: project.location,
      lock_version: project.lock_version
    }

    project_map =
      if Ecto.assoc_loaded?(project.organization) do
        Map.put(
          project_map,
          :organization,
          OrganizationView.render("organization.json", %{organization: project.organization})
        )
      else
        Map.put(project_map, :organization, nil)
      end

    project_map =
      if Ecto.assoc_loaded?(project.project_tags) do
        Map.put(project_map, :project_tags, TagView.render("index.json", %{tags: project.project_tags}))
      else
        Map.put(project_map, :project_tags, [])
      end
  end
end
