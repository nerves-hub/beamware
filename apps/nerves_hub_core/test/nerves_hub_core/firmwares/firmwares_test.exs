defmodule NervesHubCore.FirmwaresTest do
  use NervesHubCore.DataCase, async: true

  alias NervesHubCore.{Firmwares, Fixtures, Support.Fwup}
  alias Ecto.Changeset

  @uploader Application.get_env(:nerves_hub_core, :firmware_upload)

  setup do
    org = Fixtures.org_fixture()
    product = Fixtures.product_fixture(org)
    org_key = Fixtures.org_key_fixture(org)
    firmware = Fixtures.firmware_fixture(org_key, product)
    deployment = Fixtures.deployment_fixture(firmware)
    device = Fixtures.device_fixture(org, firmware)

    {:ok,
     %{
       org: org,
       org_key: org_key,
       firmware: firmware,
       deployment: deployment,
       matching_device: device,
       product: product
     }}
  end

  describe "create_firmware/2" do
    test "remote creation failure triggers transaction rollback", %{
      org: org,
      org_key: org_key,
      product: product
    } do
      firmwares = Firmwares.get_firmwares_by_product(product.id)
      upload_file_2 = fn _, _ -> {:error, :nope} end
      filepath = Fixtures.firmware_file_fixture(org_key, product)
      assert {:error, _} = Firmwares.create_firmware(org, filepath, upload_file_2: upload_file_2)
      assert ^firmwares = Firmwares.get_firmwares_by_product(product.id)
    end

    test "enforces uuid uniqueness within a product",
         %{firmware: %{upload_metadata: %{local_path: filepath}}, org: org} do
      assert {:error, %Ecto.Changeset{errors: [uuid: {"has already been taken", []}]}} =
               Firmwares.create_firmware(org, filepath)
    end

    test "enforces firmware limit within product", %{
      firmware: %{upload_metadata: %{local_path: filepath}},
      org: org,
      org_key: org_key,
      product: %{id: product_id} = product
    } do
      product_firmware_limit = Application.get_env(:nerves_hub_core, :product_firmware_limit)
      current = product_id |> Firmwares.get_firmwares_by_product() |> length()

      if current < product_firmware_limit do
        for _ <- 1..(product_firmware_limit - current) do
          _firmware = Fixtures.firmware_fixture(org_key, product)
        end
      end

      assert {:error, %Changeset{errors: [product: {"firmware limit reached", []}]}} =
               Firmwares.create_firmware(org, filepath)
    end
  end

  describe "delete_firmware/1" do
    test "remote deletion failure triggers transaction rollback", %{
      org: org,
      org_key: org_key,
      product: product
    } do
      firmware = Fixtures.firmware_fixture(org_key, product)
      @uploader.delete_file(firmware)
      assert_raise File.Error, fn -> Firmwares.delete_firmware(firmware) end
      assert {:ok, _} = Firmwares.get_firmware(org, firmware.id)
    end

    test "delete firmware", %{org: org, org_key: org_key, product: product} do
      firmware = Fixtures.firmware_fixture(org_key, product)
      :ok = Firmwares.delete_firmware(firmware)
      refute File.exists?(firmware.upload_metadata[:local_path])
      assert {:error, :not_found} = Firmwares.get_firmware(org, firmware.id)
    end
  end

  test "cannot delete firmware when it is referenced by deployment", %{
    org_key: org_key,
    product: product
  } do
    firmware = Fixtures.firmware_fixture(org_key, product)
    assert File.exists?(firmware.upload_metadata[:local_path])

    Fixtures.deployment_fixture(firmware, %{name: "a deployment"})

    assert {:error, %Changeset{}} = Firmwares.delete_firmware(firmware)
  end

  describe "get_firmwares_by_product/2" do
    test "returns firmwares", %{product: %{id: product_id} = product} do
      firmwares = Firmwares.get_firmwares_by_product(product.id)

      assert [%{product_id: ^product_id}] = firmwares
    end
  end

  describe "get_firmware/2" do
    test "returns firmwares", %{org: %{id: t_id} = org, firmware: %{id: f_id} = firmware} do
      {:ok, gotten_firmware} = Firmwares.get_firmware(org, firmware.id)

      assert %{id: ^f_id, product: %{org_id: ^t_id}} = gotten_firmware
    end
  end

  describe "verify_signature/2" do
    test "returns {:error, :no_public_keys} when no public keys are passed" do
      assert Firmwares.verify_signature("/fake/path", []) == {:error, :no_public_keys}
    end

    test "returns {:ok, key} when signature passes", %{
      org: org,
      org_key: org_key
    } do
      {:ok, signed_path} = Fwup.create_signed_firmware(org_key.name, "unsigned", "signed")

      assert Firmwares.verify_signature(signed_path, [org_key]) == {:ok, org_key}
      other_org_key = Fixtures.org_key_fixture(org)

      assert Firmwares.verify_signature(signed_path, [
               org_key,
               other_org_key
             ]) == {:ok, org_key}

      assert Firmwares.verify_signature(signed_path, [
               other_org_key,
               org_key
             ]) == {:ok, org_key}
    end

    test "returns {:error, :invalid_signature} when signature fails", %{
      org: org,
      org_key: org_key
    } do
      {:ok, signed_path} = Fwup.create_signed_firmware(org_key.name, "unsigned", "signed")
      other_org_key = Fixtures.org_key_fixture(org)

      assert Firmwares.verify_signature(signed_path, [other_org_key]) ==
               {:error, :invalid_signature}
    end

    test "returns {:error, :invalid_signature} on corrupt files", %{
      org_key: org_key
    } do
      {:ok, signed_path} = Fwup.create_signed_firmware(org_key.name, "unsigned", "signed")

      {:ok, corrupt_path} = Fwup.corrupt_firmware_file(signed_path)

      assert Firmwares.verify_signature(corrupt_path, [
               org_key
             ]) == {:error, :invalid_signature}
    end
  end
end
