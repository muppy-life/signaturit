defmodule Signaturit.Credits do
  alias Signaturit.Http
  alias Signaturit.Utils

  def get_credits do
    endpoint = Http.endpoint(:credits, ".json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
