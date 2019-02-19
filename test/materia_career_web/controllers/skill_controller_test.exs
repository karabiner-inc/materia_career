defmodule MateriaCareerWeb.SkillControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Features
  alias MateriaCareer.Features.Skill

  @create_attrs %{end_date: "2010-04-17", name: "some name", start_date: "2010-04-17", subject: "some subject"}
  @update_attrs %{end_date: "2011-05-18", name: "some updated name", start_date: "2011-05-18", subject: "some updated subject"}
  @invalid_attrs %{end_date: nil, name: nil, start_date: nil, subject: nil}

  def fixture(:skill) do
    {:ok, skill} = Features.create_skill(@create_attrs)
    skill
  end

  def fixture(:my_skill) do
    params = @create_attrs |> Map.put(:user_id, 1)
    {:ok, skill} = Features.create_skill(params)
    skill
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
    test "lists all skills", %{conn: conn} do
      conn = get conn, skill_path(conn, :index)
      assert json_response(conn, 200) == []
    end
  end

  describe "create skill" do
    test "renders skill when data is valid", %{conn: conn} do
      conn = post conn, skill_path(conn, :create), skill: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)

      conn = get conn, skill_path(conn, :show, id)
      assert json_response(conn, 200) == %{
        "id" => id,
        "end_date" => "2010-04-17",
        "name" => "some name",
        "start_date" => "2010-04-17",
        "subject" => "some subject",
        "user_id" => nil
      }
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
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get conn, skill_path(conn, :show, id)
      assert json_response(conn, 200) == %{
        "id" => id,
        "end_date" => "2011-05-18",
        "name" => "some updated name",
        "start_date" => "2011-05-18",
        "subject" => "some updated subject",
        "user_id" => nil
      }
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

  describe "my index" do
    test "lists my all skills", %{conn: conn} do
      conn = get conn, skill_path(conn, :list_my_skills)
      assert json_response(conn, 200) == []
    end
  end

  describe "create my skill" do
    test "create my skill", %{conn: conn} do
      conn = post conn, skill_path(conn, :create_my_skill), @create_attrs
      assert %{"id" => id} = json_response(conn, 201)

      conn = get conn, skill_path(conn, :show, id)
      assert json_response(conn, 200) == %{
        "id" => id,
        "end_date" => "2010-04-17",
        "name" => "some name",
        "start_date" => "2010-04-17",
        "subject" => "some subject",
        "user_id" => 1,
      }
    end
  end

  describe "udpate my skill" do
    setup [:create_my_skill]

    test "update my skill", %{conn: conn, skill: %Skill{id: id} = skill} do
      params = @update_attrs |> Map.put(:id, id)
      conn = put conn, skill_path(conn, :update_my_skill), params
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get conn, skill_path(conn, :show, id)
      assert json_response(conn, 200) == %{
        "id" => id,
        "end_date" => "2011-05-18",
        "name" => "some updated name",
        "start_date" => "2011-05-18",
        "subject" => "some updated subject",
        "user_id" => 1,
      }
    end
  end

  describe "delete my skill" do
    setup [:create_my_skill]

    test "delete my skill", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = delete conn, skill_path(conn, :delete_my_skill, %{id: id})
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, skill_path(conn, :show, skill)
      end
    end
  end

  describe "create my skills" do

    test "create my skills after delete user data", %{conn: conn} do
      # first add two data
      conn2 = post conn, skill_path(conn, :create_my_skills), skills: [@create_attrs, @create_attrs]
      assert response(conn2, 201)
      assert json_response(conn2, 201) |> Enum.count == 2

      # second add two data
      conn2 = post conn, skill_path(conn, :create_my_skills), skills: [@create_attrs, @create_attrs]
      
      # check list
      conn3 = get conn, skill_path(conn, :list_my_skills)
      assert json_response(conn3, 200) |> Enum.count == 4

      # add skill after delete 
      conn4 = post conn, skill_path(conn, :create_my_skills), %{skills: [@create_attrs, @create_attrs], is_delete: true}
      assert response(conn4, 201)
      assert json_response(conn4, 201) |> Enum.count == 2
      
      conn5 = get conn, skill_path(conn, :list_my_skills)
      assert json_response(conn5, 200) |> Enum.count == 2

    end

    test "error create my skills", %{conn: conn} do
      conn = post conn, skill_path(conn, :create_my_skills), skills: [@create_attrs, %{}]
      assert response(conn, 422)
    end
  end

  defp create_skill(_) do
    skill = fixture(:skill)
    {:ok, skill: skill}
  end

  defp create_my_skill(_) do
    skill = fixture(:my_skill)
    {:ok, skill: skill}
  end
end
