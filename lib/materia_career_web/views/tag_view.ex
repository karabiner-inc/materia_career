defmodule MateriaCareerWeb.TagView do
  use MateriaCareerWeb, :view
  alias MateriaCareerWeb.TagView

  def render("index.json", %{tags: tags}) do
    render_many(tags, TagView, "tag.json")
  end

  def render("show.json", %{tag: tag}) do
    render_one(tag, TagView, "tag.json")
  end

  def render("tag.json", %{tag: tag}) do
    %{id: tag.id, label: tag.label}
  end
end
