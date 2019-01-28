defmodule MateriaCareerWeb.RecordController do
  use MateriaCareerWeb, :controller

  alias MateriaCareer.Projects
  alias MateriaCareer.Projects.Record

  alias Ecto.Multi

  action_fallback MateriaCareerWeb.FallbackController

  def index(conn, _params) do
    records = Projects.list_records()
    render(conn, "index.json", records: records)
  end

  def create(conn, record_params) do
    with {:ok, %Record{} = record} <- Projects.create_record(record_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", record_path(conn, :show, record))
      |> render("show.json", record: record)
    end
  end

  def show(conn, %{"id" => id}) do
    record = Projects.get_record!(id)
    render(conn, "show.json", record: record)
  end

  def update(conn, record_params) do
    record = Projects.get_record!(record_params["id"])

    with {:ok, %Record{} = record} <- Projects.update_record(record, record_params) do
      render(conn, "show.json", record: record)
    end
  end

  def delete(conn, %{"id" => id}) do
    record = Projects.get_record!(id)
    with {:ok, %Record{}} <- Projects.delete_record(record) do
      send_resp(conn, :no_content, "")
    end
  end

  def create_my_record(conn, record_params) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :record, MateriaCareer.Projects, :create_my_record, [user_id, record_params])
  end

  def update_my_record(conn, record_params) do
    user_id = String.to_integer(conn.private.guardian_default_claims["sub"])

    Servicex.ControllerBase.transaction_flow(conn, :record, MateriaCareer.Projects, :update_my_record, [user_id, record_params])
  end
end
