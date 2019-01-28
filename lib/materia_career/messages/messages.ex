defmodule MateriaCareer.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false

  alias MateriaCareer.Messages.Offer
  alias MateriaUtils.Calendar.CalendarUtil
  alias Materia.Errors.BusinessError

  @repo Application.get_env(:materia, :repo)

  @doc """
  Returns the list of offers.

  ## Examples

      iex> list_offers()
      [%Offer{}, ...]

  """
  def list_offers do
    @repo.all(Offer)
  end

  @doc """
  Gets a single offer.

  Raises `Ecto.NoResultsError` if the Offer does not exist.

  ## Examples

      iex> get_offer!(123)
      %Offer{}

      iex> get_offer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_offer!(id) do
    Offer
    |> @repo.get!(id)
  end

  def get_offer_with_lock!(id) do
    Offer
    |> lock("FOR UPDATE")
    |> @repo.get!(id)
  end

  def preload_offer(offer) do
    offer = offer
    |> @repo.preload(:project)
    |> @repo.preload(:from_user)
    |> @repo.preload(:to_user)
  end

  def list_my_offer_by_status(user_id, status) do
    user = Materia.Accounts.get_user!(user_id)
    offers = Offer
    |> where(from_user_id: ^user.id)
    |> or_where(to_user_id: ^user.id)
    |> where(status: ^status)
    |> @repo.all()
    preload_offer(offers)
  end

  def list_my_project_offer_by_status(user_id, project_id_list, status) when is_list(project_id_list) do
    user = Materia.Accounts.get_user!(user_id)
    projects = list_your_projects(user)
    my_project_id_list = project_id_list
    |> Enum.filter(fn(project_id) ->
      projects
      |> Enum.any?(fn(project) ->
        project_id == project.id
      end)
    end)

    offers = Offer
    |> where([p], p.project_id in ^my_project_id_list)
    |> where(status: ^status)
    |> @repo.all()
    preload_offer(offers)
  end

  def get_my_project_offer!(_result, offer_id, project_id, status) do
    offers = Offer
    |> where(id: ^offer_id)
    |> where(project_id: ^project_id)
    |> where(status: ^status)
    |> lock("FOR UPDATE")
    |> @repo.all()

    if length(offers) != 1 do
      raise BusinessError, message: "user organizations offer length was unexpected number. offer_id:#{offer_id} project_id:#{project_id} length:#{length(offers)}"
    end

    offer = preload_offer(Enum.at(offers, 0))

    {:ok, offer}
  end

  #def get_offer_to_my_organization!(_result, user_profile, offer_id, status) do
#
  #  projects = list_your_projects(user_profile)
#
  #  _result =
  #    if Enum.any?(projects, fn(project) -> project.id == project_id end) do
  #      {:ok, offer} = get_my_project_offer!(%{}, offer_id, project_id, status)
  #    else
  #      raise RuntimeError, message: "project not found. project_id:#{project_id}"
  #    end
  #end

  def get_my_offer!(_result, offer_id, from_user_id, status) do
    offers = Offer
    |> where(id: ^offer_id)
    |> where(from_user_id: ^from_user_id)
    |> where(status: ^status)
    |> lock("FOR UPDATE")
    |> @repo.all()

    if length(offers) != 1 do
      raise BusinessError, message: "user offer length was unexpected number. offer_id:#{offer_id} from_user_id:#{from_user_id} length:#{length(offers)}"
    end

    offer = preload_offer(Enum.at(offers, 0))

    {:ok, offer}
  end

  def get_offer_to_me!(_result, offer_id, to_user_id, status) do
    offers = Offer
    |> where(id: ^offer_id)
    |> where(to_user_id: ^to_user_id)
    |> where(status: ^status)
    |> lock("FOR UPDATE")
    |> @repo.all()

    if length(offers) != 1 do
      raise BusinessError, message: "user offer length was unexpected number. offer_id:#{offer_id} to_user_id:#{to_user_id} length:#{length(offers)}"
    end

    offer = preload_offer(Enum.at(offers, 0))

    {:ok, offer}
  end

  @doc """
  Creates a offer.

  ## Examples

      iex> create_offer(%{field: value})
      {:ok, %Offer{}}

      iex> create_offer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_offer(attrs \\ %{}) do
    %Offer{}
    |> Offer.changeset(attrs)
    |> @repo.insert()
  end

  @doc """
  Updates a offer.

  ## Examples

      iex> update_offer(offer, %{field: new_value})
      {:ok, %Offer{}}

      iex> update_offer(offer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_offer(%Offer{} = offer, attrs) do
    {:ok, updated_offer} = offer
    |> Offer.update_changeset(attrs)
    |> @repo.update()
    offer = preload_offer(updated_offer)
    {:ok, offer}
  end

  @doc """
  Deletes a Offer.

  ## Examples

      iex> delete_offer(offer)
      {:ok, %Offer{}}

      iex> delete_offer(offer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_offer(%Offer{} = offer) do
    @repo.delete(offer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking offer changes.

  ## Examples

      iex> change_offer(offer)
      %Ecto.Changeset{source: %Offer{}}

  """
  def change_offer(%Offer{} = offer) do
    Offer.changeset(offer, %{})
  end

  def create_my_offer(_resutl, user_id, attr \\ %{}) do
    user = Materia.Accounts.get_user!(user_id)

    # TODO 入力されたProjectIDの有効チェック

    offer_attr = attr
    |> Map.put("from_user_id", user.id)
    |> Map.put("offer_time", CalendarUtil.now())

    {:ok, created_offer} = create_offer(offer_attr)
    offer = preload_offer(created_offer)
    {:ok, offer}
  end

  def create_my_organization_offer(_resutl, user_id, attr \\ %{}) do
    user = Materia.Accounts.get_user!(user_id)
    projects = list_your_projects(user)

    # TODO 入力されたProjectIDの妥当性チェック
    _result =
    if Enum.any?(projects, fn(project) -> project.id == attr["project_id"] end) do
      offer_attr = attr
      |> Map.put("from_user_id", user.id)
      |> Map.put("offer_time", CalendarUtil.now())

      {:ok, created_offer} = create_offer(offer_attr)
      offer = preload_offer(created_offer)
      {:ok, offer}
    else
      raise BusinessError, message: "project not found. project_id:#{attr["project_id"]}"
    end
  end

  def update_my_organization_offer(_resutl, user_id, attr \\ %{}) do
    user = Materia.Accounts.get_user!(user_id)

    #{:ok, offer} = get_offer_to_my_organization!(%{}, user_profile, attr["offer_id"], attr["project_id"], Offer.status.new)
    offer = get_offer_with_lock!(attr["offer_id"])

    _result =
    if my_organization_offer?(user, offer) do
      {:ok, offer} = update_offer(offer, attr)
    else
      raise BusinessError, message: "offer_id: #{attr["offer_id"]} is not your organization offer."
    end
  end

  def my_organization_offer?(user, offer) do
    if ! Ecto.assoc_loaded?(user.organization) do
      user = @repo.preload(user, :organization)
    end

    organization = user.organization

    if ! Ecto.assoc_loaded?(organization.projects) do
      organization = @repo.preload(organization, :projects)
    end

    project_id = offer.project_id
    projects = organization.projects

    Enum.any?(projects, fn(project) -> project.id == project_id end)
  end

  def update_my_offer(_resutl, user_id, attr \\ %{}) do
    user = Materia.Accounts.get_user!(user_id)
    with {:ok, offer} <- get_my_offer!(%{}, attr["offer_id"], user.id, Offer.status.new) do
      {:ok, offer} = update_offer(offer, attr)
    else
      _ -> raise BusinessError, message: "offer_id:#{attr["offer_id"]} is not offer to you."
    end
  end

  def answer_offer_to_my_organization(_resutl, user_id, offer_id, status, answer_message, lock_version) do
    user = Materia.Accounts.get_user!(user_id)

    offer = get_offer_with_lock!(offer_id)

    if my_organization_offer?(user, offer) do
      offer_attr = %{}
      |> Map.put("answer_time", CalendarUtil.now())
      |> Map.put("offer_id", offer_id)
      |> Map.put("status", status)
      |> Map.put("answer_message", answer_message)
      |> Map.put("lock_version", lock_version)

      {:ok, updated_offer} = update_offer(offer, offer_attr)
      loaded_offer = preload_offer(updated_offer)
      {:ok, loaded_offer}
    else
      raise BusinessError, message: "offer_id:#{offer_id} is not your organization's offer."
    end

  end

  def answer_offer_to_me(_resutl, user_id, offer_id, status, answer_message, lock_version) do
    user = Materia.Accounts.get_user!(user_id)

    with {:ok, offer} <- get_offer_to_me!(%{}, offer_id, user.id, Offer.status.new) do
      offer_attr = %{}
      |> Map.put("answer_time", CalendarUtil.now())
      |> Map.put("offer_id", offer_id)
      |> Map.put("status", status)
      |> Map.put("answer_message", answer_message)
      |> Map.put("lock_version", lock_version)

      {:ok, updated_offer} = update_offer(offer, offer_attr)
      offer = preload_offer(updated_offer)
      {:ok, offer}
    else
      _ -> raise BusinessError, message: "offer_id:#{offer_id} is not offer to you."
    end

  end

  def list_your_projects(user) do
    organization = user.organization
    |> @repo.preload(:projects)
    organization.projects
  end

end
