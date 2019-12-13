defmodule MateriaCareer.FeaturesTest do
  use MateriaCareer.DataCase

  alias MateriaCareer.Features

  describe "skills" do
    alias MateriaCareer.Features.Skill

    @valid_attrs %{end_date: ~D[2010-04-17], name: "some name", start_date: ~D[2010-04-17], subject: "some subject"}
    @update_attrs %{
      end_date: ~D[2011-05-18],
      name: "some updated name",
      start_date: ~D[2011-05-18],
      subject: "some updated subject"
    }
    @invalid_attrs %{end_date: nil, name: nil, start_date: nil, subject: nil}

    def skill_fixture(attrs \\ %{}) do
      {:ok, skill} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Features.create_skill()

      skill
    end

    test "list_skills/0 returns all skills" do
      skill = skill_fixture()
      assert Features.list_skills() == [skill]
    end

    test "get_skill!/1 returns the skill with given id" do
      skill = skill_fixture()
      assert Features.get_skill!(skill.id) == skill
    end

    test "create_skill/1 with valid data creates a skill" do
      assert {:ok, %Skill{} = skill} = Features.create_skill(@valid_attrs)
      assert skill.end_date == ~D[2010-04-17]
      assert skill.name == "some name"
      assert skill.start_date == ~D[2010-04-17]
      assert skill.subject == "some subject"
    end

    test "create_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Features.create_skill(@invalid_attrs)
    end

    test "update_skill/2 with valid data updates the skill" do
      skill = skill_fixture()
      assert {:ok, skill} = Features.update_skill(skill, @update_attrs)
      assert %Skill{} = skill
      assert skill.end_date == ~D[2011-05-18]
      assert skill.name == "some updated name"
      assert skill.start_date == ~D[2011-05-18]
      assert skill.subject == "some updated subject"
    end

    test "update_skill/2 with invalid data returns error changeset" do
      skill = skill_fixture()
      assert {:error, %Ecto.Changeset{}} = Features.update_skill(skill, @invalid_attrs)
      assert skill == Features.get_skill!(skill.id)
    end

    test "delete_skill/1 deletes the skill" do
      skill = skill_fixture()
      assert {:ok, %Skill{}} = Features.delete_skill(skill)
      assert_raise Ecto.NoResultsError, fn -> Features.get_skill!(skill.id) end
    end

    test "change_skill/1 returns a skill changeset" do
      skill = skill_fixture()
      assert %Ecto.Changeset{} = Features.change_skill(skill)
    end
  end

  describe "my skills" do
    @valid_attrs %{
      end_date: ~D[2010-04-17],
      name: "some name",
      start_date: ~D[2010-04-17],
      subject: "some subject",
      user_id: 1
    }
    @update_attrs %{
      end_date: ~D[2011-05-18],
      name: "some updated name",
      start_date: ~D[2011-05-18],
      subject: "some updated subject",
      user_id: 1
    }
    @invalid_attrs %{end_date: nil, name: nil, start_date: nil, subject: nil, user_id: nil}

    def skill_my_fixture(attrs \\ %{}) do
      {:ok, skill} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Features.create_skill()

      skill
    end

    test "list my skills" do
      skill = skill_my_fixture()
      [match_skill] = Features.list_my_skills(skill.user_id)
      assert match_skill == skill
    end
  end
end
