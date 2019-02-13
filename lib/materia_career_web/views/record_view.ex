defmodule MateriaCareerWeb.RecordView do
  use MateriaCareerWeb, :view
  alias MateriaCareerWeb.RecordView

  alias MateriaWeb.UserView
  alias MateriaCareerWeb.TagView
  alias MateriaCareerWeb.ProjectView

  def render("index.json", %{records: records}) do
    render_many(records, RecordView, "record.json")
  end

  def render("show.json", %{record: record}) do
    render_one(record, RecordView, "record.json")
  end

  def render("record.json", %{record: record}) do
    record_map = %{id: record.id,
      title: record.title,
      description: record.description,
      score: record.score,
      lock_version: record.lock_version,
    }

    record_map=
    if Ecto.assoc_loaded?(record.user) do
      Map.put(record_map, :user, UserView.render("show.json", %{user: record.user}))
    else
      Map.put(record_map, :user, nil)
    end

    record_map=
    if Ecto.assoc_loaded?(record.project) do
      Map.put(record_map, :project, ProjectView.render("show.json", %{project: record.project}))
    else
      Map.put(record_map, :project, nil)
    end

    record_map=
    if Ecto.assoc_loaded?(record.tags) do
      Map.put(record_map, :tags, TagView.render("index.json", %{tags: record.tags}))
    else
      Map.put(record_map, :tags, nil)
    end
  end
end
