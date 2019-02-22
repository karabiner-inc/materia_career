defmodule MateriaCareer.AccountsTest do
  use MateriaCareer.DataCase

  describe "users" do
    alias MateriaCareer.Accounts
    alias MateriaCareer.Features

    @valid_attrs %{
      end_date: ~D[2010-04-17],
      name: "some name",
      start_date: ~D[2010-04-17],
      subject: "some subject",
      user_id: 1
    }

    test "list_users_with_skills/0 returns all users with skills" do
      Features.create_skill(@valid_attrs)
      Features.create_skill(@valid_attrs)

      data = Accounts.list_users_with_skills()
      assert data |> Enum.count() > 0

      [%{skills: skills}] = data |> Enum.filter(fn(%{id: user_id}) -> user_id == 1 end)

      assert skills |> Enum.count() == 2
    end

    test "list_users_with_skills/1 returns all users with skills" do
      Features.create_skill(@valid_attrs)
      Features.create_skill(@valid_attrs)

      data = Accounts.list_users_with_skills(9)
      assert data |> Enum.count() == 0
    end

    test "get_user_with_skills/1 returns user with skills" do
      Features.create_skill(@valid_attrs)
      Features.create_skill(@valid_attrs)

      %{
        id: user_id,
        skills: skills} = Accounts.get_user_with_skills!(1)

      assert user_id == 1
      assert skills |> Enum.count() == 2
    end
    
  end
end
