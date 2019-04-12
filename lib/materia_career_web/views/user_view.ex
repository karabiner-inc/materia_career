defmodule MateriaCareerWeb.UserView do
  use MateriaCareerWeb, :view

  def render("index.json", %{users: users}) do
    render_many(users, MateriaCareerWeb.UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, MateriaCareerWeb.UserView, "user.json")
  end

  def render("show_non_privacy.json", %{user: user}) do
    render_one(user, MateriaCareerWeb.UserView, "user_non_privacy.json")
  end

  def render("user.json", %{user: user}) do
    skills = render_many(user.skills, MateriaCareerWeb.SkillView, "skill.json")

    render_one(user, MateriaWeb.UserView, "user.json")
    |> Map.put(:email, "mask")
    |> Map.put(:skills, skills)
  end

  def render("user_non_privacy.json", %{user: user}) do
    skills = render_many(user.skills, MateriaCareerWeb.SkillView, "skill.json")

    render_one(user, MateriaWeb.UserView, "user.json")
    |> Map.put(:skills, skills)
  end
end
