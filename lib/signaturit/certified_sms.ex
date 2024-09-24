defmodule Signaturit.CertifiedSms do
  alias Signaturit.Http
  alias Signaturit.Utils

  @type certificate_event_type() ::
          :sms_processed
          | :sms_delivered
          | :documents_opened
          | :document_opened
          | :document_downloaded
          | :certification_completed

  @type certificate_event_data() :: %{
          created_at: DateTime.t(),
          type: certificate_event_type()
        }

  @type certificate_data() :: %{
          phone: String.t(),
          events: [certificate_event_data()],
          status: :in_queue | :sent | :error
        }

  @type t() :: %__MODULE__{
          created_at: DateTime.t(),
          id: String.t(),
          certificates: [certificate_data()]
        }

  defstruct [
    :created_at,
    :id,
    :certificates
  ]

  def count_certified_sms(params) do
    endpoint = Http.endpoint(:sms, "/count.json")
    res = Http.get(endpoint, params)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def list_certified_sms(params \\ %{}) do
    endpoint = Http.endpoint(:sms, ".json")
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

  def get_certified_sms(id) do
    endpoint = Http.endpoint(:sms, "/#{id}.json")
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

  def create_certified_sms(files, recipients, body, params \\ %{}) do
    endpoint = Http.endpoint(:sms, ".json")

    parameters =
      if(is_list(recipients), do: recipients, else: List.wrap(recipients))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, recipient}, acc ->
        Utils.fill_array(acc, recipient, "recipients[#{index}]")
      end)
      |> Utils.fill_array(params, "")

    documents =
      if(is_list(files), do: files, else: List.wrap(files))
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce([], fn {index, file}, acc ->
        acc ++ [Utils.build_file(file, "attachments[#{index}]")]
      end)

    upload_body = parameters ++ documents ++ [{"body", body}]

    with {:ok, res} <- Http.upload(endpoint, upload_body) do
      res
      |> Utils.keys_to_atoms()
      |> then(&struct!(%__MODULE__{}, &1))
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end

  def download_audit_trail(sms_id, certificate_id) do
    endpoint = Http.endpoint(:sms, "/#{sms_id}/certificates/#{certificate_id}/audit_trail")
    res = Http.download(endpoint)

    with {:ok, res} <- res do
      res
      |> Utils.keys_to_atoms()
      |> then(&{:ok, &1})
    else
      {:error, msg} -> Utils.manage_error(msg, __MODULE__)
    end
  end
end
