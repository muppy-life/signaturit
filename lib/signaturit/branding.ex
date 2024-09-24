defmodule Signaturit.Branding do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          id: String.t(),
          application_texts: map(),
          templates: [any()],
          show_biometric_hash: boolean(),
          show_csv: boolean(),
          show_survey_page: boolean(),
          show_welcome_page: boolean()
        }

  defstruct [
    :created_at,
    :id,
    :application_texts,
    :templates,
    :show_biometric_hash,
    :show_csv,
    :show_survey_page,
    :show_welcome_page
  ]

  def list_brandings do
    endpoint = Http.endpoint(:brandings, ".json")
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

  def get_branding(id) do
    endpoint = Http.endpoint(:brandings, "/#{id}.json")
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

  def create_branding(params) do
    endpoint = Http.endpoint(:brandings, ".json")
    res = Http.post(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
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
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
