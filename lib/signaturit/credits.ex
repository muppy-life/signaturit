defmodule Signaturit.Credits do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t() :: %__MODULE__{
          type: String.t(),
          used_credits: integer(),
          quantity: integer(),
          remaining_credits: integer(),
          period: String.t(),
          current_period: %{
            from: DateTime.t(),
            to: DateTime.t()
          }
        }

  defstruct [
    :type,
    :used_credits,
    :quantity,
    :remaining_credits,
    :period,
    :current_period
  ]

  def get_credits do
    endpoint = Http.endpoint(:credits, ".json")
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
end
