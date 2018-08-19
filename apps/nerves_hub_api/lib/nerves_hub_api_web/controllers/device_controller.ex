defmodule NervesHubAPIWeb.DeviceController do
  use NervesHubAPIWeb, :controller

  alias NervesHubCore.Devices

  action_fallback(NervesHubAPIWeb.FallbackController)

  def create(%{assigns: %{org: org}} = conn, params) do
    params = Map.put(params, "org_id", org.id)

    with {:ok, device} <- Devices.create_device(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", device_path(conn, :show, org.name, device))
      |> render("show.json", device: device)
    end
  end

  def show(%{assigns: %{org: org}} = conn, %{"device_identifier" => identifier}) do
    with {:ok, device} <- Devices.get_device_by_identifier(org, identifier) do
      render(conn, "show.json", device: device)
    end
  end
end
