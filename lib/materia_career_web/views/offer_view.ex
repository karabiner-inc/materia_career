defmodule MateriaCareerWeb.OfferView do
  use MateriaCareerWeb, :view
  alias MateriaCareerWeb.OfferView

  alias MateriaCareerWeb.ProjectView
  alias MateriaWeb.UserView
  alias MateriaCareer.Messages.Offer

  def render("index.json", %{offers: offers}) do
    render_many(offers, OfferView, "offer.json")
  end

  def render("show.json", %{offer: offer}) do
    render_one(offer, OfferView, "offer.json")
  end

  def render("offer.json", %{offer: offer}) do
    result_map = %{id: offer.id,
      message_subject: offer.message_subject,
      offer_message: offer.offer_message,
      answer_message: offer.answer_message,
      status: offer.status,
      status_disp: Offer.get_status_disp(offer.status),
      project_id: offer.project_id,
      from_user_id: offer.from_user_id,
      to_user_id: offer.to_user_id,
      offer_time: offer.offer_time,
      answer_time: offer.answer_time,
      chat_room_id: offer.chat_room_id,
      lock_version: offer.lock_version
    }
    result_map =
    if Ecto.assoc_loaded?(offer.project) && offer.project != nil do
      Map.put(result_map, :project, ProjectView.render("project.json", %{project: offer.project}))
    else
      Map.put(result_map, :project, nil)
    end
    result_map =
    if Ecto.assoc_loaded?(offer.from_user) && offer.from_user != nil do
      Map.put(result_map, :from_user, 
        UserView.render("user.json", %{user: offer.from_user})
        |> Map.put(:email, "mask")
      )
    else
      Map.put(result_map, :from_user, nil)
    end
    result_map =
    if Ecto.assoc_loaded?(offer.to_user) && offer.to_user != nil do
      Map.put(result_map, :to_user, 
        UserView.render("user.json", %{user: offer.to_user})
        |> Map.put(:email, "mask")
        )
    else
      Map.put(result_map, :to_user, nil)
    end
  end
end
