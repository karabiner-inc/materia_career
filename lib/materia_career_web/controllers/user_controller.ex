defmodule MateriaCareerWeb.UserController do
  use MateriaCareerWeb, :controller

  action_fallback MateriaCareerWeb.FallbackController
  alias MateriaCareer.Accounts

  def index(conn, _params) do
    users = Accounts.list_users_with_skills()
    render(conn, "index.json", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user_with_skills!(id)
    render(conn, "show.json", user: user)
  end

  def show_me(conn, _) do
    user_id = MateriaWeb.ControllerBase.get_user_id(conn)
    user = Accounts.get_user_with_skills!(user_id)
    render(conn, "show.json", user: user)
  end


end