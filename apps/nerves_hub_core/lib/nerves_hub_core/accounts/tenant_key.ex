defmodule NervesHubCore.Accounts.TenantKey do
  use Ecto.Schema

  import Ecto.Changeset

  alias NervesHubCore.Accounts.Tenant
  alias NervesHubCore.Firmwares.Firmware
  alias __MODULE__

  @type t :: %__MODULE__{}

  @required_params [:tenant_id, :name, :key]
  @optional_params []

  schema "tenant_keys" do
    belongs_to(:tenant, Tenant)
    has_many(:firmwares, Firmware)

    field(:name, :string)
    field(:key, :string)

    timestamps()
  end

  def changeset(%TenantKey{} = tenant, params) do
    tenant
    |> cast(params, @required_params ++ @optional_params)
    |> validate_required(@required_params)
    |> unique_constraint(:name, name: :tenant_keys_tenant_id_name_index)
    |> unique_constraint(:key)
  end

  def update_changeset(%TenantKey{id: _} = tenant, params) do
    # don't allow tenant_id to change
    tenant
    |> cast(params, @required_params -- [:tenant_id])
    |> validate_required(@required_params)
    |> unique_constraint(:name, name: :tenant_keys_tenant_id_name_index)
    |> unique_constraint(:key)
  end
end
