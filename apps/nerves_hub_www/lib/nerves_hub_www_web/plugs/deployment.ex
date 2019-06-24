defmodule NervesHubWWWWeb.Plugs.Deployment do
  use NervesHubWWWWeb, :plug

  alias NervesHubWebCore.Deployments

  def init(opts) do
    opts
  end

  def call(
        %{params: %{"deployment_name" => deployment_name}, assigns: %{product: product}} = conn,
        _opts
      ) do
    with {:ok, deployment} <- Deployments.get_deployment_by_name(product, deployment_name) do
      conn
      |> assign(:deployment, deployment)
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
