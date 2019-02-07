defmodule MateriaCareerWeb.RecordControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Projects
  alias MateriaCareer.Projects.Record

  @create_attrs %{discription: "some discription", title: "some title", user_id: 1, project_id: nil}
  @update_attrs %{
    discription: "some updated discription",
    title: "some updated title",
    user_id: 1,
    project_id: nil
  }
  @invalid_attrs %{discription: nil, title: nil, user_id: nil}

  def fixture(:record) do
    {:ok, record} = Projects.create_record(@create_attrs)
    record
  end

  setup %{conn: conn} do
    %{"access_token" => access_token} = 
      conn
      |> post(authenticator_path(conn, :sign_in), %{email: "hogehoge@example.com", password: "hogehoge"})
      |> json_response(201)
    conn = conn 
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer " <> access_token)
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all records", %{conn: conn} do
      conn = get(conn, record_path(conn, :index))
      assert json_response(conn, 200) |> Enum.count > 0
    end
  end

  describe "create record" do
    test "renders record when data is valid", %{conn: conn} do
      conn = post(conn, record_path(conn, :create), @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, record_path(conn, :show, id))

      assert json_response(conn, 200) == %{
               "id" => id,
               "discription" => "some discription",
               "title" => "some title",
               "lock_version" => 1,
               "project" => nil,
               "tags" => nil,
               "user" => nil
             }
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, record_path(conn, :create), @invalid_attrs)
    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  describe "update record" do
    setup [:create_record]

    test "renders record when data is valid", %{conn: conn, record: %Record{id: id} = record} do
      conn = put(conn, record_path(conn, :update, record), @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, record_path(conn, :show, id))

      assert json_response(conn, 200) == %{
               "id" => id,
               "discription" => "some updated discription",
               "title" => "some updated title",
               "lock_version" => 2,
               "project" => nil,
               "tags" => nil,
               "user" => nil
             }
    end

    # test "renders errors when data is invalid", %{conn: conn, record: record} do
    #   conn = put(conn, record_path(conn, :update, record), @invalid_attrs)
    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  describe "delete record" do
    setup [:create_record]

    test "deletes chosen record", %{conn: conn, record: record} do
      conn = delete(conn, record_path(conn, :delete, record))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, record_path(conn, :show, record))
      end)
    end
  end

  describe "records API with authentication" do


    test "get list-my-records", %{conn: conn} do
      conn = get(conn, record_path(conn, :list_my_records))
      assert json_response(conn, 200) |> Enum.count > 0
    end

    test "post create-my-record", %{conn: conn} do
      req = %{
        title: "title1",
        discription: "discription1",
        project_id: 1
      }
      conn = post(conn, record_path(conn, :create_my_record, req))
      assert response(conn, 201)
    end

    test "post update-my-record", %{conn: conn} do

      req = %{
        title: "title1",
        discription: "discription1",
        project_id: 1
      }
      create_conn = post(conn, record_path(conn, :create_my_record, req))
      data = json_response(create_conn, 201)

      req = %{
        id: data["id"],
        title: "updated title1",
        discription: "updated discription1",
        project_id: 1
      }
      conn = post(conn, record_path(conn, :update_my_record, req))
      assert response(conn, 201)
    end

  end

  defp create_record(_) do
    record = fixture(:record)
    {:ok, record: record}
  end
end
