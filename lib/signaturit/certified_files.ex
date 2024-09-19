defmodule Signaturit.CertifiedFiles do
  alias Signaturit.Http
  alias Signaturit.Utils

  def get_certified_file(id) do
    endpoint = Http.endpoint(:files, "/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def upload_certified_file(file_path) do
    endpoint = Http.endpoint(:files, ".json")
    body = Utils.build_file(file_path, "file")
    res = Http.upload(endpoint, body)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end