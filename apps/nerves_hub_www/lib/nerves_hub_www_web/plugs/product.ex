defmodule NervesHubWWWWeb.Plugs.Product do
  use NervesHubWWWWeb, :plug

  alias NervesHubWebCore.Products

  def init(opts) do
    opts
  end

  def call(%{params: %{"product_name" => product_name}} = conn, _opts) do
    with {:ok, product} <-
           Products.get_product_by_org_id_and_name(conn.assigns.org.id, product_name) do
      conn
      |> assign(:product, product)
    else
      _error ->
        conn
        |> put_status(:not_found)
        |> put_view(NervesHubWWWWeb.ErrorView)
        |> render("404.html")
        |> halt
    end
  end
end
