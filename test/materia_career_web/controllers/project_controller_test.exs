defmodule MateriaCareerWeb.ProjectControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Projects
  alias MateriaCareer.Projects.Project

  @create_attrs %{
    back_ground_img_url: "some back_ground_img_url",
    description: "some description",
    thumbnail_img_url: "some thumbnail_img_url",
    overview: "some overview",
    title: "some title",
    project_category: "some project category",
    project_start_date: "2010-04-17 14:00:00.000000Z",
    project_end_date: "2010-04-17 15:00:00.000000Z",
    work_start_date: "2010-04-18 20:00:00.000000Z",
    work_end_date: "2010-04-18 21:00:00.000000Z",
    status: 1,
    pay: 200,
    work_style: "remote",
    location: "remote",
    organization_id: 1
  }
  @update_attrs %{
    back_ground_img_url: "some updated back_ground_img_url",
    description: "some updated description",
    thumbnail_img_url: "some updated thumbnail_img_url",
    overview: "some updated overview",
    title: "some updated title",
    project_category: "some updated project category",
    project_start_date: "2010-04-18 14:00:00.000000Z",
    project_end_date: "2010-04-18 15:00:00.000000Z",
    work_start_date: "2010-04-19 20:00:00.000000Z",
    work_end_date: "2010-04-19 21:00:00.000000Z",
    status: 2,
    pay: 256,
    work_style: "remote updated",
    location: "remote updated",
    organization_id: 1
  }
  @invalid_attrs %{
    back_ground_img_url: nil,
    description: nil,
    thumbnail_img_url: nil,
    overview: nil,
    title: nil,
    project_category: nil,
    project_start_date: nil,
    project_end_date: nil,
    work_start_date: nil,
    work_end_date: nil,
    status: nil,
    pay: nil,
    work_style: nil,
    location: nil,
    organization_id: nil
  }

  def fixture(:project) do
    {:ok, project} = Projects.create_project(@create_attrs)
    project
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, project_path(conn, :index))
      assert  [_] = json_response(conn, 200)
    end
  end

  describe "create project" do
    test "renders project when data is valid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, project_path(conn, :show, id))

      assert json_response(conn, 200) == %{
               "id" => id,
               "back_ground_img_url" => "some back_ground_img_url",
               "description" => "some description",
               "thumbnail_img_url" => "some thumbnail_img_url",
               "overview" => "some overview",
               "title" => "some title",
               "location" => "remote",
               "lock_version" => 1,
               "organization" => %{
                 "addresses" => [],
                 "back_ground_img_url" => "https://hogehoge.com/ib_img.jpg",
                 "hp_url" => "https://hogehoge.inc",
                 "id" => 1,
                 "lock_version" => 1,
                 "name" => "hogehoge.inc",
                 "one_line_message" => "let's do this.",
                 "phone_number" => nil,
                 "profile_img_url" => "https://hogehoge.com/prof_img.jpg",
                 "status" => 1,
                 "users" => []
               },
               "pay" => 200,
               "project_category" => "some project category",
               "project_end_date" => "2010-04-17T15:00:00.000000Z",
               "project_start_date" => "2010-04-17T14:00:00.000000Z",
               "project_tags" => [],
               "status" => 1,
               "status_disp" => "募集前",
               "work_end_date" => "2010-04-18T21:00:00.000000Z",
               "work_start_date" => "2010-04-18T20:00:00.000000Z",
               "work_style" => "remote"
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    setup [:create_project]

    test "renders project when data is valid", %{conn: conn, project: %Project{id: id} = project} do
      conn = put(conn, project_path(conn, :update, project), @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, project_path(conn, :show, id))

      assert json_response(conn, 200) == %{
               "id" => id,
               "back_ground_img_url" => "some updated back_ground_img_url",
               "description" => "some updated description",
               "thumbnail_img_url" => "some updated thumbnail_img_url",
               "overview" => "some updated overview",
               "title" => "some updated title",
               "location" => "remote updated",
               "lock_version" => 2,
               "organization" => %{
                 "addresses" => [],
                 "back_ground_img_url" => "https://hogehoge.com/ib_img.jpg",
                 "hp_url" => "https://hogehoge.inc",
                 "id" => 1,
                 "lock_version" => 1,
                 "name" => "hogehoge.inc",
                 "one_line_message" => "let's do this.",
                 "phone_number" => nil,
                 "profile_img_url" => "https://hogehoge.com/prof_img.jpg",
                 "status" => 1,
                 "users" => []
               },
               "pay" => 256,
               "project_category" => "some updated project category",
               "project_end_date" => "2010-04-18T15:00:00.000000Z",
               "project_start_date" => "2010-04-18T14:00:00.000000Z",
               "project_tags" => [],
               "status" => 2,
               "status_disp" => "募集中",
               "work_end_date" => "2010-04-19T21:00:00.000000Z",
               "work_start_date" => "2010-04-19T20:00:00.000000Z",
               "work_style" => "remote updated"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put(conn, project_path(conn, :update, project), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, project: project} do
      conn = delete(conn, project_path(conn, :delete, project))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, project_path(conn, :show, project))
      end)
    end
  end

  defp create_project(_) do
    project = fixture(:project)
    {:ok, project: project}
  end
end
