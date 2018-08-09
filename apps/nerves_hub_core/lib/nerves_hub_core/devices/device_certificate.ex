defmodule NervesHubCore.Devices.DeviceCertificate do
  use Ecto.Schema
  import Ecto.Changeset

  alias NervesHubCore.Devices.{Device, DeviceCertificate}

  @type t :: %__MODULE__{}

  @required_params [:serial, :valid_before, :valid_after, :device_id]

  schema "device_certificates" do
    belongs_to(:device, Device)

    field(:serial, :string)
    field(:valid_after, :utc_datetime)
    field(:valid_before, :utc_datetime)

    timestamps()
  end

  def changeset(%DeviceCertificate{} = device_certificate, params) do
    device_certificate
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(:serial, name: :device_certificates_device_id_serial_index)
  end
end
