defmodule Signaturit.Subscription do
  alias Signaturit.Http
  alias Signaturit.Utils

  def list_subscriptions(params \\ %{}) do
    endpoint = Http.endpoint(:subscriptions, ".json")
    res = Http.get(endpoint, params)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def get_subscription(id) do
    endpoint = Http.endpoint(:subscriptions, "/#{id}.json")
    res = Http.get(endpoint)
    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_subscription(url, events) do
    endpoint = Http.endpoint(:subscriptions, ".json")
    params =
      (if is_list(events), do: events, else: List.wrap(events))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, event}, acc ->
        Utils.fill_array(acc, event, "events[#{index}]")
      end)
      |> Utils.fill_array(url, "url")
    with {:ok, res} <- Http.upload(endpoint, params) do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_subscription(id, events \\ nil, url \\ nil) do
    endpoint = Http.endpoint(:subscriptions, "/#{id}.json")
    events_body =
      events
      |> List.wrap()
      |> Enum.with_index()
      |> Enum.reduce([], fn {event, index}, acc ->
        Utils.fill_array(acc, event, "events[#{index}]")
      end)
    url_body = if url, do: [{"url", url}], else: []
    params = events_body ++ url_body
    with {:ok, res} <- Http.patch(endpoint, params) do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def delete_subscription(id) do
    endpoint = Http.endpoint(:subscriptions, "/#{id}.json")
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
