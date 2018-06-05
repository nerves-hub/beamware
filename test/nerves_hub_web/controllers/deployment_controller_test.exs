defmodule NervesHubWeb.DeploymentControllerTest do
  use NervesHubWeb.ConnCase.Browser

  alias NervesHub.Fixtures

  describe "index" do
    test "lists all deployments", %{conn: conn} do
      conn = get(conn, deployment_path(conn, :index))
      assert html_response(conn, 200) =~ "Deployments"
    end
  end

  describe "new deployment" do
    test "renders form with valid request params", %{conn: conn, current_tenant: tenant} do
      firmware = Fixtures.firmware_fixture(tenant)
      conn = get(conn, deployment_path(conn, :new), deployment: %{firmware_id: firmware.id})

      assert html_response(conn, 200) =~ "Create Deployment"
    end

    test "redirects with invalid firmware", %{conn: conn} do
      conn = get(conn, deployment_path(conn, :new), deployment: %{firmware_id: -1})

      assert redirected_to(conn, 302) =~ deployment_path(conn, :new)
    end

    test "redirects form with no firmware", %{conn: conn} do
      conn = get(conn, deployment_path(conn, :new))

      assert redirected_to(conn, 302) =~ firmware_path(conn, :index)
    end
  end

  describe "create deployment" do
    test "redirects to index when data is valid", %{conn: conn, current_tenant: tenant} do
      firmware = Fixtures.firmware_fixture(tenant)

      deployment_params = %{
        firmware_id: firmware.id,
        tenant_id: tenant.id,
        name: "Test Deployment ABC",
        tags: "beta, beta-edge",
        version: "< 1.0.0",
        is_active: true
      }

      # check that we end up in the right place
      create_conn = post(conn, deployment_path(conn, :create), deployment: deployment_params)
      assert redirected_to(create_conn, 302) =~ deployment_path(conn, :index)

      # check that the proper creation side effects took place
      conn = get(conn, deployment_path(conn, :index))
      assert html_response(conn, 200) =~ deployment_params.name
      assert html_response(conn, 200) =~ "Inactive"
    end
  end
end
