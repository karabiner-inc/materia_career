defmodule MateriaCareerWeb.OfferControllerTest do
  use MateriaCareerWeb.ConnCase

  alias MateriaCareer.Messages
  alias MateriaCareer.Messages.Offer

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all offers", %{conn: conn} do
      conn = get(conn, offer_path(conn, :index))
      assert json_response(conn, 200) == []
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

  defp create_offer(_) do
    offer = fixture(:offer)
    {:ok, offer: offer}
  end
end
