defmodule MateriaCareer.Messages.Offer do
  use Ecto.Schema
  import Ecto.Changeset


  schema "offers" do
    field :answer_message, :string
    field :lock_version, :integer, default: 1
    field :offer_message, :string
    field :message_subject, :string
    field :status, :integer, default: 1
    field :offer_time, :utc_datetime
    field :answer_time, :utc_datetime
    field :chat_room_id, :integer
    belongs_to :project, MateriaCareer.Projects.Project
    belongs_to :from_user, Materia.Accounts.User, [define_field: :from_user_id]
    belongs_to :to_user, Materia.Accounts.User, [define_field: :to_user_id]

    timestamps()
  end

  @doc false
  def changeset(offer, attrs) do
    offer
    |> cast(attrs, [:message_subject, :offer_message, :answer_message, :status, :lock_version, :from_user_id, :to_user_id, :project_id, :offer_time, :answer_time, :chat_room_id])
    |> validate_required([:message_subject, :offer_message, :from_user_id, :offer_time])
  end
  def update_changeset(offer, attrs) do
    offer
    |> cast(attrs, [:message_subject, :offer_message, :answer_message, :status, :lock_version, :from_user_id, :to_user_id, :project_id, :offer_time, :answer_time, :chat_room_id])
    |> validate_required([:lock_version])
    |> optimistic_lock(:lock_version)
  end
  def status() do
    %{
      new: 1, #新規
      accept: 2, #承認
      reject: 8, #拒否
      canceled: 9, #キャンセル
    }
  end

  def get_status_disp(status_value) do
    disp_map = %{
      1 => "新規",
      2 => "承認",
      8 => "拒否",
      9 => "キャンセル",
    }
    disp_map[status_value]
  end
end
