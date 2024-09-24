defmodule Signaturit.Contacts do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          email: String.t(),
          id: String.t(),
          name: String.t()
        }

  defstruct [
    :created_at,
    :email,
    :id,
    :name
  ]

  def list_contacts do
    endpoint = Http.endpoint(:contacts, ".json")
    res = Http.get(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> Enum.map(&struct!(%__MODULE__{}, &1))
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
      |> then(&struct!(%__MODULE__{}, &1))
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
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_contact(id, email, name) do
    endpoint = Http.endpoint(:contacts, "/#{id}.json")

    params =
      %{}
      |> then(&((email && Map.put(&1, "email", email)) || &1))
      |> then(&((name && Map.put(&1, "name", name)) || &1))

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

  def delete_contact(id) do
    endpoint = Http.endpoint(:contacts, "/#{id}.json")
    res = Http.delete(endpoint)

    with {:ok, []} <- res do
      res
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
