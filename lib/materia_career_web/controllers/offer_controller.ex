defmodule MateriaCareerWeb.OfferController do
  use MateriaCareerWeb, :controller

  alias MateriaCareer.Messages
  alias MateriaCareer.Messages.Offer

  action_fallback MateriaWeb.FallbackController

  def index(conn, _params) do
    offers = Messages.list_offers()
    render(conn, "index.json", offers: offers)
  end

  def create(conn, %{"offer" => offer_params}) do
    with {:ok, %Offer{} = offer} <- Messages.create_offer(offer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", offer_path(conn, :show, offer))
      |> render("show.json", offer: offer)
    end
  end

  def show(conn, %{"id" => id}) do
    offer = Messages.get_offer!(id)
    render(conn, "show.json", offer: offer)
  end

  def update(conn, %{"id" => id, "offer" => offer_params}) do
    offer = Messages.get_offer!(id)

    with {:ok, %Offer{} = offer} <- Messages.update_offer(offer, offer_params) do
      render(conn, "show.json", offer: offer)
    end
  end

  def delete(conn, %{"id" => id}) do
    offer = Messages.get_offer!(id)
    with {:ok, %Offer{}} <- Messages.delete_offer(offer) do
      send_resp(conn, :no_content, "")
    end
  end

  def list_my_offers(conn, %{"status" => status}) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])
    offers = Messages.list_my_offer_by_status(user_id, status)
    render(conn, "index.json", offers: offers)
  end

  def list_my_projects_offers(conn, %{"status" => status, "project_id_list" => project_id_list}) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])
    offers = Messages.list_my_project_offer_by_status(user_id, project_id_list, status)
    render(conn, "index.json", offers: offers)
  end

  def create_my_offer(conn, offer_params) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :offer, MateriaCareer.Messages, :create_my_offer, [user_id, offer_params])
  end

  def create_my_organization_offer(conn, offer_params) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :offer, MateriaCareer.Messages, :create_my_organization_offer, [user_id, offer_params])
  end

  def update_my_organization_offer(conn, offer_params) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :offer, MateriaCareer.Messages, :update_my_organization_offer, [user_id, offer_params])
  end

  def update_my_offer(conn, offer_params) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :offer, MateriaCareer.Messages, :update_my_offer, [user_id, offer_params])
  end

  def answer_offer_to_my_organization(conn, %{"offer_id" => offer_id, "status" => status, "answer_message" => answer_message, "lock_version" => lock_version}) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :offer, MateriaCareer.Messages, :answer_offer_to_my_organization, [user_id, offer_id, status, answer_message, lock_version])
  end

  def answer_offer_to_me(conn, %{"offer_id" => offer_id, "status" => status, "answer_message" => answer_message, "lock_version" => lock_version}) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :offer, MateriaCareer.Messages, :answer_offer_to_me, [user_id, offer_id, status, answer_message, lock_version])
  end
end
