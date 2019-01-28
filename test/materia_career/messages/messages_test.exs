defmodule MateriaCareer.MessagesTest do
  use MateriaCareer.DataCase

  alias MateriaCareer.Messages

  describe "offers" do
    alias MateriaCareer.Messages.Offer

    @valid_attrs %{
      answer_message: "some answer_message",
      message_subject: "some message_subject",
      offer_message: "some offer_message",
      status: 1,
      from_user_id: 1,
      to_user_id: 2,
      project_id: 1,
      offer_time: "2019-01-01T12:00:00.000000Z",
      answer_time: "2019-01-01T12:00:00.000000Z"
    }
    @update_attrs %{
      answer_message: "some updated answer_message",
      message_subject: "some updated message_subject",
      offer_message: "some updated offer_message",
      status: 2,
      from_user_id: 1,
      to_user_id: 2,
      project_id: 1,
      offer_time: "2019-01-01T12:00:00.000000Z",
      answer_time: "2019-01-01T12:00:00.000000Z"
    }
    @invalid_attrs %{
      answer_message: nil,
      message_subject: nil,
      # lock_version: nil,
      offer_message: nil,
      status: nil,
      from_user_id: nil,
      to_user_id: nil,
      project_id: nil,
      offer_time: nil,
      answer_time: nil
    }

    def offer_fixture(attrs \\ %{}) do
      {:ok, offer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messages.create_offer()

      offer
    end

    test "list_offers/0 returns all offers" do
      offer = offer_fixture()
      assert Messages.list_offers() |> Enum.filter(fn(x) -> x.id == offer.id end) |> Enum.at(0) == offer
    end

    test "get_offer!/1 returns the offer with given id" do
      offer = offer_fixture()
      assert Messages.get_offer!(offer.id) == offer
    end

    test "create_offer/1 with valid data creates a offer" do
      assert {:ok, %Offer{} = offer} = Messages.create_offer(@valid_attrs)
      assert offer.answer_message == "some answer_message"
      assert offer.lock_version == 1
      assert offer.offer_message == "some offer_message"
      assert offer.status == 1
      assert offer.message_subject == "some message_subject"
      assert offer.from_user_id == 1
      assert offer.to_user_id == 2
      assert offer.project_id == 1
      assert offer.offer_time == DateTime.from_naive!(~N[2019-01-01 12:00:00.000000Z], "Etc/UTC")
      assert offer.answer_time == DateTime.from_naive!(~N[2019-01-01 12:00:00.000000Z], "Etc/UTC")
    end

    test "create_offer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_offer(@invalid_attrs)
    end

    test "update_offer/2 with valid data updates the offer" do
      offer = offer_fixture()
      assert {:ok, offer} = Messages.update_offer(offer, @update_attrs)
      assert %Offer{} = offer
      assert offer.answer_message == "some updated answer_message"
      assert offer.lock_version == 2
      assert offer.offer_message == "some updated offer_message"
      assert offer.status == 2
      assert offer.message_subject == "some updated message_subject"
      assert offer.from_user_id == 1
      assert offer.to_user_id == 2
      assert offer.project_id == 1
      assert offer.offer_time == DateTime.from_naive!(~N[2019-01-01 12:00:00.000000Z], "Etc/UTC")
      assert offer.answer_time == DateTime.from_naive!(~N[2019-01-01 12:00:00.000000Z], "Etc/UTC")
    end

    test "delete_offer/1 deletes the offer" do
      offer = offer_fixture()
      assert {:ok, %Offer{}} = Messages.delete_offer(offer)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_offer!(offer.id) end
    end

    test "change_offer/1 returns a offer changeset" do
      offer = offer_fixture()
      assert %Ecto.Changeset{} = Messages.change_offer(offer)
    end
  end
end
