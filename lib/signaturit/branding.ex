defmodule Signaturit.Branding do
  alias Signaturit.Http
  alias Signaturit.Utils

  def list_brandings do
    endpoint = Http.endpoint(:brandings, ".json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_branding(id) do
    endpoint = Http.endpoint(:brandings, "/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_branding(params) do
    endpoint = Http.endpoint(:brandings, ".json")
    res = Http.post(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_branding(id, params) do
    endpoint = Http.endpoint(:brandings, "/#{id}.json")
    res = Http.patch(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
