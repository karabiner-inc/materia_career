defmodule MateriaCareerWeb.SkillControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Features
  alias MateriaCareer.Features.Skill

  @create_attrs %{end_date: ~D[2010-04-17], name: "some name", start_date: ~D[2010-04-17], subject: "some subject"}
  @update_attrs %{end_date: ~D[2011-05-18], name: "some updated name", start_date: ~D[2011-05-18], subject: "some updated subject"}
  @invalid_attrs %{end_date: nil, name: nil, start_date: nil, subject: nil}

  def fixture(:skill) do
    {:ok, skill} = Features.create_skill(@create_attrs)
    skill
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all skills", %{conn: conn} do
      conn = get conn, skill_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create skill" do
    test "renders skill when data is valid", %{conn: conn} do
      conn = post conn, skill_path(conn, :create), skill: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, skill_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "end_date" => ~D[2010-04-17],
        "name" => "some name",
        "start_date" => ~D[2010-04-17],
        "subject" => "some subject"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, skill_path(conn, :create), skill: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update skill" do
    setup [:create_skill]

    test "renders skill when data is valid", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = put conn, skill_path(conn, :update, skill), skill: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, skill_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "end_date" => ~D[2011-05-18],
        "name" => "some updated name",
        "start_date" => ~D[2011-05-18],
        "subject" => "some updated subject"}
    end

    test "renders errors when data is invalid", %{conn: conn, skill: skill} do
      conn = put conn, skill_path(conn, :update, skill), skill: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete skill" do
    setup [:create_skill]

    test "deletes chosen skill", %{conn: conn, skill: skill} do
      conn = delete conn, skill_path(conn, :delete, skill)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, skill_path(conn, :show, skill)
      end
    end
  end

  defp create_skill(_) do
    skill = fixture(:skill)
    {:ok, skill: skill}
  end
end
