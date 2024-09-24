defmodule Signaturit.Team.User do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t :: %__MODULE__{
          id: String.t(),
          email: String.t(),
          role: String.t(),
          created_at: String.t(),
          name: String.t(),
          position: String.t(),
          status: :active | :inactive | :pending,
          token: String.t()
        }

  defstruct [
    :id,
    :email,
    :role,
    :created_at,
    :name,
    :position,
    :status,
    :token
  ]

  def list_team_users do
    endpoint = Http.endpoint(:team, "/users.json")
    res = Http.get(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> Enum.map(&struct!(__MODULE__, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_user(id) do
    endpoint = Http.endpoint(:team, "/user/#{id}.json")
    res = Http.get(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def invite_user_to_team(email, role) do
    endpoint = Http.endpoint(:team, "/users.json")
    params = %{email: email, role: role}
    res = Http.post(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_user_role(id, role) do
    endpoint = Http.endpoint(:team, "/users/#{id}.json")
    params = %{role: role}
    res = Http.patch(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def delete_user(id) do
    endpoint = Http.endpoint(:team, "/users/#{id}.json")
    res = Http.delete(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
