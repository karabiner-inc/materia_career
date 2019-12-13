defmodule MateriaCareer.ProjectControllerTest do
  use MateriaCareer.DataCase

  alias MateriaCareer.Projects

  describe "projects" do
    @valid_attrs %{
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
      "status" => 1,
      "pay" => 200,
      "work_style" => "remote",
      "location" => "remote"
    }

    @update_valid_attrs %{
      "back_ground_img_url" => "some updated back_ground_img_url",
      "description" => "some updated description",
      "thumbnail_img_url" => "some updated thumbnail_img_url",
      "overview" => "some updated overview",
      "title" => "some updated title",
      "project_category" => "some updated project category",
      "project_start_date" => "2010-05-17 14:00:00Z",
      "project_end_date" => "2010-05-17 15:00:00Z",
      "work_start_date" => "2010-05-18 20:00:00Z",
      "work_end_date" => "2010-05-18 21:00:00Z",
      "status" => 2,
      "pay" => 300,
      "work_style" => "updated remote",
      "location" => "updated remote"
    }

    def project_fixture(attrs \\ %{}) do
      {:ok, project} =
        attrs
        |> Map.put("organization_id", 1)
        |> Enum.into(@valid_attrs)
        |> Projects.create_project()

      project
    end

    test "list_projects/0" do
      project = project_fixture()
      project = Projects.get_project!(project.id)
      assert Projects.list_projects() |> Enum.filter(fn x -> x.id == project.id end) |> Enum.at(0) == project
    end

    test "list_project_by_user_id/2" do
      project = project_fixture()
      project = Projects.get_project!(project.id)
      assert Projects.list_project_by_user_id(1, [1]) |> Enum.at(0) == project
    end

    test "get_project!/1" do
      project = project_fixture()
      project = Projects.get_project!(project.id)
      assert project.back_ground_img_url == "some back_ground_img_url"
      assert project.description == "some description"
      assert project.thumbnail_img_url == "some thumbnail_img_url"
      assert project.overview == "some overview"
      assert project.title == "some title"
      assert project.project_category == "some project category"
      assert project.project_start_date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert project.project_end_date == DateTime.from_naive!(~N[2010-04-17 15:00:00.000000Z], "Etc/UTC")
      assert project.work_start_date == DateTime.from_naive!(~N[2010-04-18 20:00:00.000000Z], "Etc/UTC")
      assert project.work_end_date == DateTime.from_naive!(~N[2010-04-18 21:00:00.000000Z], "Etc/UTC")
      assert project.status == 1
      assert project.pay == 200
      assert project.work_style == "remote"
      assert project.location == "remote"
      assert project.organization.id == 1
    end

    test "create_project/1" do
      {:ok, project} = Projects.create_project(@valid_attrs)
      assert project.back_ground_img_url == "some back_ground_img_url"
      assert project.description == "some description"
      assert project.thumbnail_img_url == "some thumbnail_img_url"
      assert project.overview == "some overview"
      assert project.title == "some title"
      assert project.project_category == "some project category"
      assert project.project_start_date == DateTime.from_naive!(~N[2010-04-17 14:00:00Z], "Etc/UTC")
      assert project.project_end_date == DateTime.from_naive!(~N[2010-04-17 15:00:00Z], "Etc/UTC")
      assert project.work_start_date == DateTime.from_naive!(~N[2010-04-18 20:00:00Z], "Etc/UTC")
      assert project.work_end_date == DateTime.from_naive!(~N[2010-04-18 21:00:00Z], "Etc/UTC")
      assert project.status == 1
      assert project.pay == 200
      assert project.work_style == "remote"
      assert project.location == "remote"
      assert project.organization_id == nil
    end

    test "create_my_project/3" do
      {:ok, project} = Projects.create_my_project(%{}, 1, @valid_attrs)
      assert project.back_ground_img_url == "some back_ground_img_url"
      assert project.description == "some description"
      assert project.thumbnail_img_url == "some thumbnail_img_url"
      assert project.overview == "some overview"
      assert project.title == "some title"
      assert project.project_category == "some project category"
      assert project.project_start_date == DateTime.from_naive!(~N[2010-04-17 14:00:00Z], "Etc/UTC")
      assert project.project_end_date == DateTime.from_naive!(~N[2010-04-17 15:00:00Z], "Etc/UTC")
      assert project.work_start_date == DateTime.from_naive!(~N[2010-04-18 20:00:00Z], "Etc/UTC")
      assert project.work_end_date == DateTime.from_naive!(~N[2010-04-18 21:00:00Z], "Etc/UTC")
      assert project.status == 1
      assert project.pay == 200
      assert project.work_style == "remote"
      assert project.location == "remote"
      assert project.organization_id == 1
    end

    test "update_project/2" do
      {:ok, project} =
        project_fixture()
        |> Projects.update_project(@update_valid_attrs)

      assert project.back_ground_img_url == "some updated back_ground_img_url"
      assert project.description == "some updated description"
      assert project.thumbnail_img_url == "some updated thumbnail_img_url"
      assert project.overview == "some updated overview"
      assert project.title == "some updated title"
      assert project.project_category == "some updated project category"
      assert project.project_start_date == DateTime.from_naive!(~N[2010-05-17 14:00:00Z], "Etc/UTC")
      assert project.project_end_date == DateTime.from_naive!(~N[2010-05-17 15:00:00Z], "Etc/UTC")
      assert project.work_start_date == DateTime.from_naive!(~N[2010-05-18 20:00:00Z], "Etc/UTC")
      assert project.work_end_date == DateTime.from_naive!(~N[2010-05-18 21:00:00Z], "Etc/UTC")
      assert project.status == 2
      assert project.pay == 300
      assert project.work_style == "updated remote"
      assert project.location == "updated remote"
      assert project.organization_id == 1
    end

    test "update_project/3" do
      project = project_fixture()
      attrs = @update_valid_attrs |> Map.put("id", project.id)
      {:ok, project} = Projects.update_project(%{}, 1, attrs)
      assert project.back_ground_img_url == "some updated back_ground_img_url"
      assert project.description == "some updated description"
      assert project.thumbnail_img_url == "some updated thumbnail_img_url"
      assert project.overview == "some updated overview"
      assert project.title == "some updated title"
      assert project.project_category == "some updated project category"
      assert project.project_start_date == DateTime.from_naive!(~N[2010-05-17 14:00:00Z], "Etc/UTC")
      assert project.project_end_date == DateTime.from_naive!(~N[2010-05-17 15:00:00Z], "Etc/UTC")
      assert project.work_start_date == DateTime.from_naive!(~N[2010-05-18 20:00:00Z], "Etc/UTC")
      assert project.work_end_date == DateTime.from_naive!(~N[2010-05-18 21:00:00Z], "Etc/UTC")
      assert project.status == 2
      assert project.pay == 300
      assert project.work_style == "updated remote"
      assert project.location == "updated remote"
      assert project.organization_id == 1
    end

    test "merge_tags/2 and merge_project_tags/2" do
      project =
        project_fixture()
        |> Projects.merge_tags(["test1", "test2"])

      assert project.project_tags |> Enum.at(0) |> Map.get(:label) == "test1"
      assert project.project_tags |> Enum.at(1) |> Map.get(:label) == "test2"
    end

    test "delete_project/1" do
      assert {:ok, _} =
               project_fixture()
               |> Projects.delete_project()
    end
  end
end
