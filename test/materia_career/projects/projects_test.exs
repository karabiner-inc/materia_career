defmodule MateriaCareer.ProjectControllerTest do
  use MateriaCareer.DataCase

  alias MateriaCareer.Projects

  describe "projects" do

    @valid_attrs %{
      back_ground_img_url: "some back_ground_img_url",
      description: "some description",
      thumbnail_img_url: "some thumbnail_img_url",
      overview: "some overview",
      title: "some title",
      project_category: "some project category",
      project_start_date: "2010-04-17 14:00:00Z",
      project_end_date: "2010-04-17 15:00:00Z",
      work_start_date: "2010-04-18 20:00:00Z",
      work_end_date: "2010-04-18 21:00:00Z",
      status: 1,
      pay: 200,
      work_style: "remote",
      location: "remote",
      organization_id: 1
    }

    def project_fixture(attrs \\ %{}) do
      {:ok, project} = 
        attrs
        |> Enum.into(@valid_attrs)
        |> Projects.create_project()
      project
    end

    test "list_projects/0" do
      project = project_fixture()
      project = Projects.get_project!(project.id)
      assert Projects.list_projects() |> Enum.at(0) == project
    end

    test "list_project_by_user_id/2" do
      project = project_fixture()
      project = Projects.get_project!(project.id)
      assert Projects.list_project_by_user_id(1, [1]) |> Enum.at(0) == project
    end

    test "get_project!/1" do
      project = project_fixture()
      project = Projects.get_project!(project.id)
      assert project.back_ground_img_url ==  "some back_ground_img_url"
      assert project.description ==  "some description"
      assert project.thumbnail_img_url ==  "some thumbnail_img_url"
      assert project.overview ==  "some overview"
      assert project.title ==  "some title"
      assert project.project_category ==  "some project category"
      assert project.project_start_date ==  DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert project.project_end_date ==  DateTime.from_naive!(~N[2010-04-17 15:00:00.000000Z], "Etc/UTC")
      assert project.work_start_date ==  DateTime.from_naive!(~N[2010-04-18 20:00:00.000000Z], "Etc/UTC")
      assert project.work_end_date ==  DateTime.from_naive!(~N[2010-04-18 21:00:00.000000Z], "Etc/UTC")
      assert project.status ==  1
      assert project.pay ==  200
      assert project.work_style ==  "remote"
      assert project.location ==  "remote"
      assert project.organization.id == 1
    end

    test "create_project/1" do
      {:ok, project} = Projects.create_project(@valid_attrs)
      assert project.back_ground_img_url ==  "some back_ground_img_url"
      assert project.description ==  "some description"
      assert project.thumbnail_img_url ==  "some thumbnail_img_url"
      assert project.overview ==  "some overview"
      assert project.title ==  "some title"
      assert project.project_category ==  "some project category"
      assert project.project_start_date ==  DateTime.from_naive!(~N[2010-04-17 14:00:00Z], "Etc/UTC")
      assert project.project_end_date ==  DateTime.from_naive!(~N[2010-04-17 15:00:00Z], "Etc/UTC")
      assert project.work_start_date ==  DateTime.from_naive!(~N[2010-04-18 20:00:00Z], "Etc/UTC")
      assert project.work_end_date ==  DateTime.from_naive!(~N[2010-04-18 21:00:00Z], "Etc/UTC")
      assert project.status ==  1
      assert project.pay ==  200
      assert project.work_style ==  "remote"
      assert project.location ==  "remote"
      assert project.organization_id == 1
    end

    test "create_my_project/3" do
      {:ok, project} = Projects.create_my_project(1, @valid_attrs)
      assert project.back_ground_img_url ==  "some back_ground_img_url"
      assert project.description ==  "some description"
      assert project.thumbnail_img_url ==  "some thumbnail_img_url"
      assert project.overview ==  "some overview"
      assert project.title ==  "some title"
      assert project.project_category ==  "some project category"
      assert project.project_start_date ==  DateTime.from_naive!(~N[2010-04-17 14:00:00Z], "Etc/UTC")
      assert project.project_end_date ==  DateTime.from_naive!(~N[2010-04-17 15:00:00Z], "Etc/UTC")
      assert project.work_start_date ==  DateTime.from_naive!(~N[2010-04-18 20:00:00Z], "Etc/UTC")
      assert project.work_end_date ==  DateTime.from_naive!(~N[2010-04-18 21:00:00Z], "Etc/UTC")
      assert project.status ==  1
      assert project.pay ==  200
      assert project.work_style ==  "remote"
      assert project.location ==  "remote"
      assert project.organization_id == 1
    end 

    test "update_project/3" do
      
    end

    test "merge_tags/2" do
    end

    test "merge_project_tags/2" do
    end

    test "update_project/2" do
      
    end

    test "delete_project/1" do
      
    end

  end

  describe "project_tags" do
    test "get_project_tag_by_project_id_with_lock/2" do
    end

    test "create_project_tag/1" do
      
    end

    test "update_project_tag/2" do
      
    end

    test "delete_project_tag/1" do
    end

  end
end