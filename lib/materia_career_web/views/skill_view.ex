defmodule MateriaCareerWeb.SkillView do
  use MateriaCareerWeb, :view
  alias MateriaCareerWeb.SkillView

  def render("index.json", %{skills: skills}) do
    render_many(skills, SkillView, "skill.json")
  end

  def render("show.json", %{skill: skill}) do
    render_one(skill, SkillView, "skill.json")
  end

  def render("skill.json", %{skill: skill}) do
    %{id: skill.id,
      subject: skill.subject,
      name: skill.name,
      start_date: skill.start_date,
      end_date: skill.end_date,
      user_id: skill.user_id
    }
  end
end
