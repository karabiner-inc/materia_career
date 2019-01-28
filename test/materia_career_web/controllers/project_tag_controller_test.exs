defmodule MateriaCareerWeb.ProjectTagControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Projects
  alias MateriaCareer.Projects.ProjectTag

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  # def fixture(:project_tag) do
  #   {:ok, project_tag} = Projects.create_project_tag(@create_attrs)
  #   project_tag
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all project_tags", %{conn: conn} do
  #     conn = get conn, project_tag_path(conn, :index)
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create project_tag" do
  #   test "renders project_tag when data is valid", %{conn: conn} do
  #     conn = post conn, project_tag_path(conn, :create), project_tag: @create_attrs
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get conn, project_tag_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id}
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post conn, project_tag_path(conn, :create), project_tag: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update project_tag" do
  #   setup [:create_project_tag]

  #   test "renders project_tag when data is valid", %{conn: conn, project_tag: %ProjectTag{id: id} = project_tag} do
  #     conn = put conn, project_tag_path(conn, :update, project_tag), project_tag: @update_attrs
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get conn, project_tag_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id}
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, project_tag: project_tag} do
  #     conn = put conn, project_tag_path(conn, :update, project_tag), project_tag: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete project_tag" do
  #   setup [:create_project_tag]

  #   test "deletes chosen project_tag", %{conn: conn, project_tag: project_tag} do
  #     conn = delete conn, project_tag_path(conn, :delete, project_tag)
  #     assert response(conn, 204)
  #     assert_error_sent 404, fn ->
  #       get conn, project_tag_path(conn, :show, project_tag)
  #     end
  #   end
  # end

  # defp create_project_tag(_) do
  #   project_tag = fixture(:project_tag)
  #   {:ok, project_tag: project_tag}
  # end
end
