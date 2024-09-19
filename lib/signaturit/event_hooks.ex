defmodule Signaturit.EventHooks do
  alias Signaturit.Http
  alias Signaturit.Utils

  def list_event_hooks do
    endpoint = Http.endpoint(:event_hooks, "")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def retry_event_hook(event_hook_id) do
    endpoint = Http.endpoint(:event_hooks, "/#{event_hook_id}/retry")
    res = Http.get(endpoint)
    with {:ok, %{}} <- res do
      {:ok, %{}}
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
