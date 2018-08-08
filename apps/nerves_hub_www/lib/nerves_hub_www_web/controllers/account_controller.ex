defmodule NervesHubWWWWeb.AccountController do
  use NervesHubWWWWeb, :controller

  alias Ecto.Changeset
  alias NervesHubCore.Accounts
  alias NervesHubCore.Accounts.User

  @session_key "auth_user_id"

  plug(NervesHubWWWWeb.Plugs.AllowUninvitedSignups when action in [:new, :create])

  def new(conn, _params) do
    render(conn, "new.html", changeset: %Changeset{data: %User{}}, layout: false)
  end

  def create(conn, params) do
    params["user"]
    |> Accounts.create_tenant_with_user()
    |> case do
      {:ok, {_tenant, %User{id: user_id} = usr}} ->
        conn
        |> put_session(@session_key, user_id)
        |> render_success()

      {:error, changeset} ->
        conn = put_flash(conn, :error, "Sign up Failed")
        render_error(conn, "new.html", changeset: changeset, layout: false)
    end
  end


  def edit(conn, _params) do
    conn
    |> render(
      "edit.html",
      changeset: %Changeset{data: conn.assigns.user}
    )
  end

  def update(conn, params) do
    conn.assigns.user
    |> Accounts.update_user(params["user"])
    |> case do
      {:ok, _user} ->
        render_success(conn)

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Signup Failed")
        |> render_error("edit.html", changeset: changeset,
                                           layout: false)
    end
  end

  def invite(conn, %{"token" => token} = _) do
    with {:ok, invite} <- Accounts.get_valid_invite(token),
         {:ok, tenant} <- Accounts.get_tenant(invite.tenant_id) do
      render(
        conn,
        "invite.html",
        changeset: %Changeset{data: invite},
        tenant: tenant,
        token: token
      )
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid or expired invite")
        |> redirect(to: "/")
    end
  end

  def accept_invite(conn, %{"user" => user_params, "token" => token} = _) do
    with {:ok, invite} <- Accounts.get_valid_invite(token),
         {:ok, tenant} <- Accounts.get_tenant(invite.tenant_id),
         {:ok, _user} <- Accounts.create_user_from_invite(invite, tenant, user_params) do
      conn
      |> put_flash(:info, "Account successfully created, login below")
      |> redirect(to: "/")
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid or expired invite")
        |> redirect(to: "/")
    end
  end

end
