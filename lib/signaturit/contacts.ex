defmodule Signaturit.Contacts do
  alias Signaturit.Http
  alias Signaturit.Utils

  def list_contacts do
    endpoint = Http.endpoint(:contacts, ".json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_contact(id) do
    endpoint = Http.endpoint(:contacts, "/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_contact(email, name) do
    endpoint = Http.endpoint(:contacts, ".json")
    params =
      []
      |> Utils.fill_array(email, "email")
      |> Utils.fill_array(name, "name")

    res = Http.upload(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_contact(id, email, name) do
    endpoint = Http.endpoint(:contacts, "/#{id}.json")
    params =
      %{
        email: email,
        name: name
      }
    res = Http.patch(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def delete_contact(id) do
    endpoint = Http.endpoint(:contacts, "/#{id}.json")
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
