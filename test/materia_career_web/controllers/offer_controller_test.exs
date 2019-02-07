defmodule MateriaCareerWeb.OfferControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Messages
  alias MateriaCareer.Messages.Offer
  alias MateriaCareer.Projects

  @create_attrs %{
    answer_message: "some answer_message",
    offer_message: "some offer_message",
    status: 1,
    message_subject: "some message_subject",
    from_user_id: 1,
    to_user_id: 2,
    project_id: 1,
    offer_time: "2019-01-01T12:00:00.000000Z",
    answer_time: "2019-01-01T12:00:00.000000Z"
  }
  @update_attrs %{
    answer_message: "some updated answer_message",
    offer_message: "some updated offer_message",
    status: 2,
    message_subject: "some updated message_subject",
    from_user_id: 1,
    to_user_id: 2,
    project_id: 1,
    offer_time: "2019-01-01T12:00:00.000000Z",
    answer_time: "2019-01-01T12:00:00.000000Z"
  }
  @invalid_attrs %{
    answer_message: nil,
    offer_message: nil,
    status: nil,
    message_subject: nil,
    from_user_id: nil,
    to_user_id: nil,
    project_id: nil,
    offer_time: nil,
    answer_time: nil
  }

  def fixture(:offer) do
    {:ok, offer} = Messages.create_offer(@create_attrs)
    offer
  end

  def fixture(:project) do
    {:ok, project} = MateriaCareer.Projects.create_my_project(%{}, 1, %{
      "back_ground_img_url" => "some back_ground_img_url",
      "description" => "some description",
      "thumbnail_img_url" => "some thumbnail_img_url",
      "overview" => "some overview",
      "title" => "some title",
      "project_category" => "some project category",
      "project_start_date" => "2010-04-17 14:00:00Z",
      "project_end_date" => "2010-04-17 15:00:00Z",
      "work_start_date" => "2010-04-18 20:00:00Z",
      "work_end_date" => "2010-04-18 21:00:00Z",
      "status" => 2, #募集中
      "pay" => 200,
      "work_style" => "remote",
      "location" => "remote",
    })
    project
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
    test "lists all offers", %{conn: conn} do
      conn = get(conn, offer_path(conn, :index))
      assert json_response(conn, 200) |> Enum.count > 0
    end
  end

  describe "create offer" do
    test "renders offer when data is valid", %{conn: conn} do
      conn = post(conn, offer_path(conn, :create), offer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, offer_path(conn, :show, id))

      assert json_response(conn, 200) == %{
               "id" => id,
               "answer_message" => "some answer_message",
               "lock_version" => 1,
               "offer_message" => "some offer_message",
               "status" => 1,
               "status_disp" => "新規",
               "message_subject" => "some message_subject",
               "from_user_id" => 1,
               "to_user_id" => 2,
               "from_user" => nil,
               "to_user" => nil,
               "project_id" => 1,
               "project" => nil,
               "offer_time" => "2019-01-01T12:00:00.000000Z",
               "answer_time" => "2019-01-01T12:00:00.000000Z"
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, offer_path(conn, :create), offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update offer" do
    setup [:create_offer]

    test "renders offer when data is valid", %{conn: conn, offer: %Offer{id: id} = offer} do
      conn = put(conn, offer_path(conn, :update, offer), offer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, offer_path(conn, :show, id))

      assert json_response(conn, 200) == %{
               "id" => id,
               "answer_message" => "some updated answer_message",
               "lock_version" => 2,
               "offer_message" => "some updated offer_message",
               "status" => 2,
               "status_disp" => "承認",
               "message_subject" => "some updated message_subject",
               "from_user_id" => 1,
               "to_user_id" => 2,
               "from_user" => nil,
               "to_user" => nil,
               "project_id" => 1,
               "project" => nil,
               "offer_time" => "2019-01-01T12:00:00.000000Z",
               "answer_time" => "2019-01-01T12:00:00.000000Z"
             }
    end

    # test "renders errors when data is invalid", %{conn: conn, offer: offer} do
    #   conn = put(conn, offer_path(conn, :update, offer), offer: @invalid_attrs)
    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  describe "delete offer" do
    setup [:create_offer]

    test "deletes chosen offer", %{conn: conn, offer: offer} do
      conn = delete(conn, offer_path(conn, :delete, offer))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, offer_path(conn, :show, offer))
      end)
    end
  end

  describe "offers API with authentication" do

    setup [:create_project]

    test "get list-my-offers", %{conn: conn} do
      conn = get(conn, offer_path(conn, :list_my_offers, %{status: 1}))
      assert json_response(conn, 200) |> Enum.count > 0
    end

    test "post list-my-projects-offers", %{conn: conn} do
      req = %{status: 1, project_id_list: [1]}
      conn = post(conn, offer_path(conn, :list_my_projects_offers, req))
      assert json_response(conn, 200) == []
    end

    test "post create-my-organization-offer", %{conn: conn, project: project} do
      offer = %{
        project_id: project.id,
        offer_message: "test offer",
        message_subject: "test",
        status: 1,
      }
      conn = post(conn, offer_path(conn, :create_my_organization_offer, offer))
      assert response(conn, 201)
    end

    test "post create-my-offer", %{conn: conn, project: project} do
      offer = %{
        project_id: project.id,
        offer_message: "test offer",
        message_subject: "test",
        status: 1,
      }
      conn = post(conn, offer_path(conn, :create_my_offer, offer))
      assert response(conn, 201)
    end

    test "post update-my-organization-offer", %{conn: conn, project: project} do
      offer = %{
        project_id: project.id,
        offer_message: "test offer",
        message_subject: "test",
        status: 1,
      }
      create_conn = post(conn, offer_path(conn, :create_my_organization_offer, offer))
      %{"id" => id} = json_response(create_conn, 201)
      update_offer = %{
        project_id: project.id,
        offer_id: id,
        offer_message: "updated test offer",
        message_subject: "udpated test",
        status: 2,
      }
      conn = post(conn, offer_path(conn, :update_my_organization_offer, update_offer))
      assert response(conn, 201)
    end

    test "post update-my-offer", %{conn: conn, project: project} do
      offer = %{
        project_id: project.id,
        offer_message: "test offer",
        message_subject: "test",
        status: 1,
      }
      create_conn = post(conn, offer_path(conn, :create_my_offer, offer))
      %{"id" => id} = json_response(create_conn, 201)
      update_offer = %{
        project_id: project.id,
        offer_id: id,
        offer_message: "updated test offer",
        message_subject: "udpated test",
        status: 2,
      }
      conn = post(conn, offer_path(conn, :update_my_offer, update_offer))
      assert response(conn, 201)
    end

    test "post answer-offer-to-my-organization", %{conn: conn, project: project} do
      offer = %{
        project_id: project.id,
        offer_message: "test offer",
        message_subject: "test",
        status: 1,
      }
      create_conn = post(conn, offer_path(conn, :create_my_organization_offer, offer))
      %{"id" => id, "lock_version" => lock_version} = json_response(create_conn, 201)

      update_offer = %{
        offer_id: id,
        answer_message: "answer message",
        status: 2,
        lock_version: lock_version
      }
      conn = post(conn, offer_path(conn, :answer_offer_to_my_organization, update_offer))
      assert response(conn, 201)
    end

    test "post answer-offer-to-me", %{conn: conn, project: project} do

      update_offer = %{
        offer_id: 2,
        answer_message: "answer message",
        status: 2,
        lock_version: 1
      }

      conn = post(conn, offer_path(conn, :answer_offer_to_me, update_offer))
      assert response(conn, 201)
    end
  end

  defp create_offer(_) do
    offer = fixture(:offer)
    {:ok, offer: offer}
  end

  defp create_project(_) do
    project = fixture(:project)
    {:ok, project: project}
  end
end
