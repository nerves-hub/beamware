defmodule NervesHubCore.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def up do
    create table(:products) do
      add(:name, :string)
      add(:tenant_id, references(:tenants, null: false))

      timestamps()
    end

    alter table(:devices) do
      add(:product_id, references(:products, null: false))
      remove(:product)
    end

    alter table(:firmwares) do
      add(:product_id, references(:products, null: false))
      remove(:product)
    end

    alter table(:deployments) do
      add(:product_id, references(:products, null: false))
      remove(:tenant_id)
    end

    create(index(:products, [:tenant_id]))
    unique_index(:products, [:tenant_id, :name], name: :products_tenant_id_name_index)
    unique_index(:deployments, [:product_id, :name], name: :deployments_product_id_name_index)
  end

  def down do
    drop(table(:products))

    alter table(:devices) do
      remove(:product_id)
      add(:product, :string)
    end

    alter table(:firmwares) do
      remove(:product_id)
      add(:product, :string)
    end

    alter table(:deployments) do
      remove(:product_id)
      add(:tenant_id, references(:tenants, null: false))
    end
  end
end
