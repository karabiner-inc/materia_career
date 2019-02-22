defmodule MateriaCareerWeb.UserController do
  use MateriaCareerWeb, :controller

  action_fallback MateriaCareerWeb.FallbackController
  alias MateriaCareer.Accounts

  def index(conn, params) do
    status = Map.get(params, "status")
    status = cond do
      is_nil(status) -> nil
      is_binary(status) -> String.to_integer(status)
      is_integer(status) -> status
      true -> nil
    end
    users = Accounts.list_users_with_skills(status)
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