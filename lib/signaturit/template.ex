defmodule Signaturit.Template do
  alias Signaturit.Http
  alias Signaturit.Utils

  def list_templates(params) do
    endpoint = Http.endpoint(:templates, ".json")
    res = Http.get(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
