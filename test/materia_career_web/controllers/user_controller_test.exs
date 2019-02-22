defmodule MateriaCareerWeb.UserControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Accounts
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

  describe "list users" do
    setup [:create_my_skill]

    test "list users with skills", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = get conn, user_path(conn, :index)
      data = json_response(conn, 200)
      assert data |> Enum.count >  0

      skill = data 
      |> Enum.filter(fn(%{"id" => user_id}) -> user_id == 1 end)
      |> Enum.at(0)
      |> Map.get("skills")
      |> Enum.at(0)

      assert skill["id"] == id
    end

    test "list users with skills status==9", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = get conn, user_path(conn, :index), status: 9
      data = json_response(conn, 200)
      assert data |> Enum.count ==  0
    end

  end
  

  describe "get user" do
    setup [:create_my_skill]

    test "get user with skills", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = get conn, user_path(conn, :show, 1)

      %{
        "id" => user_id,
        "skills" => skills
      } = json_response(conn, 200)

      assert user_id == 1

      skill = skills |> Enum.at(0)

      assert skill["id"] == id
    end
  end

  describe "show me" do
    setup [:create_my_skill]

    test "show me with skills", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = get conn, user_path(conn, :show_me)
      
      %{
        "id" => user_id,
        "skills" => skills
      } = json_response(conn, 200)

      assert user_id == 1

      skill = skills |> Enum.at(0)

      assert skill["id"] == id
    end
  end

  defp create_my_skill(_) do
    skill = fixture(:my_skill)
    {:ok, skill: skill}
  end
end
