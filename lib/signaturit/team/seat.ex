defmodule Signaturit.Team.Seat do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t :: %__MODULE__{
          email: String.t(),
          id: String.t(),
          status: :active | :inactive | :pending
        }

  defstruct [
    :email,
    :id,
    :status
  ]

  def list_team_seats do
    endpoint = Http.endpoint(:team, "/seats.json")
    res = Http.get(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> Enum.map(&struct!(__MODULE__, &1))
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
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
