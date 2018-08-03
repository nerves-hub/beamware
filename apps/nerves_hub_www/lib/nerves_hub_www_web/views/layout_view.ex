defmodule NervesHubWWWWeb.LayoutView do
  use NervesHubWWWWeb, :view

  alias NervesHubCore.Accounts.User

  def navigation_links(conn) do
    [
      {conn.assigns.tenant.name, tenant_path(conn, :edit, conn.assigns.tenant.id)},
      {"Products", product_path(conn, :index)},
      {"All Devices", device_path(conn, :index)},
      {"Account", account_path(conn, :edit)}
    ]
  end

  def logged_in?(%{assigns: %{user: %User{}}}), do: true
  def logged_in?(_), do: false
end
