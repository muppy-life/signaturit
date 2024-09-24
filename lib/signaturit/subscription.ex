defmodule Signaturit.Subscription do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          events: [String.t()],
          id: String.t(),
          url: String.t()
        }

  defstruct [
    :created_at,
    :events,
    :id,
    :url
  ]

  def list_subscriptions(params \\ %{}) do
    endpoint = Http.endpoint(:subscriptions, ".json")
    res = Http.get(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> Enum.map(&struct!(%__MODULE__{}, &1))
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
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def create_subscription(url, events) do
    endpoint = Http.endpoint(:subscriptions, ".json")

    params =
      if(is_list(events), do: events, else: List.wrap(events))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, event}, acc ->
        Utils.fill_array(acc, event, "events[#{index}]")
      end)
      |> Utils.fill_array(url, "url")

    with {:ok, res} <- Http.upload(endpoint, params) do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def update_subscription(id, events \\ nil, url \\ nil) do
    endpoint = Http.endpoint(:subscriptions, "/#{id}.json")

    params =
      %{}
      |> then(&((events && Map.put_new(&1, "events", events)) || &1))
      |> then(&((url && Map.put_new(&1, "url", url)) || &1))

    with {:ok, res} <- Http.patch(endpoint, params) do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
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
