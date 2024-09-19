defmodule Signaturit.Team do
  alias Signaturit.Http
  alias Signaturit.Utils

  def list_team_users do
    endpoint = Http.endpoint(:team, "/users.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def list_team_seats do
    endpoint = Http.endpoint(:team, "/seats.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
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
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def remove_seat(id) do
    endpoint = Http.endpoint(:team, "/seats/#{id}.json")
    res = Http.delete(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def list_team_groups do
    endpoint = Http.endpoint(:team, "/groups.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_team_group(id) do
    endpoint = Http.endpoint(:team, "/groups/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_team_group(params) do
    endpoint = Http.endpoint(:team, "/groups.json")
    res = Http.post(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_group(id, params) do
    endpoint = Http.endpoint(:team, "/groups/#{id}.json")
    res = Http.patch(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def delete_group(id) do
    endpoint = Http.endpoint(:team, "/groups/#{id}.json")
    res = Http.delete(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def add_manager(group_id, user_id) do
    endpoint = Http.endpoint(:team, "/groups/#{group_id}/managers/#{user_id}.json")
    res = Http.post(endpoint, %{})
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def remove_manager(group_id, manager_id) do
    endpoint = Http.endpoint(:team, "/groups/#{group_id}/managers/#{manager_id}.json")
    res = Http.delete(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def add_member(group_id, user_id) do
    endpoint = Http.endpoint(:team, "/groups/#{group_id}/members/#{user_id}.json")
    res = Http.post(endpoint, %{})
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def delete_member(group_id, member_id) do
    endpoint = Http.endpoint(:team, "/groups/#{group_id}/members/#{member_id}.json")
    res = Http.delete(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
