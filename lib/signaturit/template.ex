defmodule Signaturit.Template do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          id: String.t(),
          name: String.t()
        }

  defstruct [
    :created_at,
    :id,
    :name
  ]

  def list_templates(params \\ %{}) do
    endpoint = Http.endpoint(:templates, ".json")
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
end
